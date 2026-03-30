# ② 아키텍처 리뷰 (Feature-Sliced Design)

FSD 아키텍처 준수 여부를 검증한다. FSD 구조가 아닌 프로젝트는 이 단계를 건너뛴다.

## FSD 감지

아래 디렉토리 중 3개 이상 존재하면 FSD 프로젝트로 판단:
- `app/`, `pages/`, `widgets/`, `features/`, `entities/`, `shared/`
- `src/app/`, `src/pages/`, `src/widgets/`, `src/features/`, `src/entities/`, `src/shared/`

## FSD 6개 레이어 (상위 → 하위)

```
app        ← 최상위: 라우팅, 프로바이더, 글로벌 설정
pages      ← 페이지 단위 조합
widgets    ← entities + features를 조합한 독립 블록
features   ← 사용자 행동/인터랙션 (예: 장바구니 담기, 로그인)
entities   ← 비즈니스 객체와 표현 (user, product)
shared     ← 최하위: 유틸, UI 킷, 타입
```

## 체크리스트

### 의존성 방향 (핵심)

- [ ] **상위 → 하위만 허용**: features는 entities, shared를 import 가능. entities는 features를 import 불가.
- [ ] **같은 레이어 간 import 금지**: features/A가 features/B를 직접 import하면 위반.

허용되는 의존성 방향:
```
app → pages → widgets → features → entities → shared
         ↘      ↘         ↘          ↘
          shared  shared    shared     shared
```

**위반 예시와 해결책**:

| 위반 | 코드 | 해결 방법 |
|------|------|----------|
| 역방향 import | `entities/user`에서 `features/auth` import | 공통 로직을 `shared/`로 내리거나, `entities/user`가 필요한 인터페이스를 정의하고 `features/auth`에서 주입 |
| 같은 레이어 간 | `features/cart`에서 `features/product` import | 공유 데이터를 `entities/`로 내리거나, 상위 레이어(widgets/pages)에서 두 feature를 조합 |
| shared → 상위 | `shared/api`에서 `entities/user` 타입 import | 제네릭 타입을 `shared/types`에 정의하고, 구체 타입은 `entities/`에서 확장 |

### public API 접근

- [ ] 슬라이스 내부 파일에 직접 접근하지 않는가?
- [ ] 각 슬라이스에 `index.ts` (barrel export)가 존재하는가?

**위반 예시와 해결책**:

```typescript
// ❌ 내부 파일 직접 접근
import { authStore } from 'features/auth/model/store'
import { UserCard } from 'entities/user/ui/UserCard'

// ✅ public API를 통한 접근
import { authStore } from 'features/auth'
import { UserCard } from 'entities/user'
```

barrel export가 없는 경우:
```typescript
// features/auth/index.ts 생성
export { authStore } from './model/store'
export { LoginForm } from './ui/LoginForm'
// 외부에 노출할 것만 선별적으로 export
```

### 비즈니스 로직 배치

- [ ] API 호출이 적절한 레이어에 있는가?
- [ ] UI 컴포넌트에 비즈니스 로직이 섞여있지 않은가?
- [ ] shared 레이어에 비즈니스 로직이 포함되어 있지 않은가?

**API 호출 배치 기준**:

| API 종류 | 배치 레이어 | 예시 |
|---------|-----------|------|
| 범용 HTTP 클라이언트 (axios 래퍼, fetch 설정) | `shared/api` | `shared/api/client.ts` |
| 특정 엔티티 CRUD | `entities/*/api` | `entities/user/api/getUser.ts` |
| 비즈니스 기능에 묶인 API | `features/*/api` | `features/checkout/api/processPayment.ts` |
| 페이지 로딩용 데이터 조합 | `pages/*/api` 또는 `pages/*/model` | `pages/dashboard/model/loadDashboard.ts` |

**UI에 비즈니스 로직이 섞인 경우**:

```typescript
// ❌ 컴포넌트에 비즈니스 로직 혼재
function OrderCard({ order }) {
  const discount = order.total > 100 ? order.total * 0.1 : 0  // 비즈니스 로직
  const finalPrice = order.total - discount                     // 비즈니스 로직
  return <div>{finalPrice}원</div>
}

// ✅ 로직 분리
// entities/order/lib/calcPrice.ts
export function calcFinalPrice(order) {
  const discount = order.total > 100 ? order.total * 0.1 : 0
  return order.total - discount
}

// entities/order/ui/OrderCard.tsx
import { calcFinalPrice } from '../lib/calcPrice'
function OrderCard({ order }) {
  return <div>{calcFinalPrice(order)}원</div>
}
```

**shared에 비즈니스 로직이 있는 경우**:

```typescript
// ❌ shared에 비즈니스 로직
// shared/lib/orderUtils.ts
export function isEligibleForDiscount(user, order) { ... }

// ✅ 비즈니스 로직은 entities 이상으로
// entities/order/lib/discount.ts
export function isEligibleForDiscount(user, order) { ... }
```

판단 기준: "이 로직이 특정 도메인 개념(user, order, product 등)을 알아야 하는가?" → Yes면 shared가 아닌 entities 이상에 배치.

### 세그먼트 구조

- [ ] 각 슬라이스가 적절한 세그먼트로 분리되어 있는가?

**표준 세그먼트**:

| 세그먼트 | 역할 | 포함하는 것 |
|---------|------|-----------|
| `ui/` | 화면 표시 | 컴포넌트, 스타일 |
| `model/` | 상태·로직 | store, hooks, 비즈니스 로직 |
| `api/` | 외부 통신 | API 호출, 요청/응답 타입 |
| `lib/` | 유틸리티 | 헬퍼 함수, 상수, 포매터 |
| `config/` | 설정 | 환경 설정, 상수 맵 |

```
features/auth/
├── ui/          ← LoginForm, AuthButton
├── model/       ← authStore, useAuth
├── api/         ← login(), logout()
├── lib/         ← validatePassword()
└── index.ts     ← public API
```

## 판정 기준

| 이슈 | 심각도 |
|------|--------|
| 하위 → 상위 import (역방향) | ⚠️ WARNING |
| 같은 레이어 간 직접 import | ⚠️ WARNING |
| public API 우회 접근 | ⚠️ WARNING |
| barrel export(index.ts) 누락 | ⚠️ WARNING |
| shared에 비즈니스 로직 | ⚠️ WARNING |
| UI 컴포넌트에 비즈니스 로직 혼재 | ⚠️ WARNING |
| 세그먼트 미분리 (모든 코드가 한 파일) | ⚠️ WARNING |

> 아키텍처 위반은 모두 WARNING으로 처리한다. 자동 수정하지 않고 review 문서에 경고와 해결 방향을 함께 남긴다.
