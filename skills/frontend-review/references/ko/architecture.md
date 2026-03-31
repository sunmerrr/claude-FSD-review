# ② 아키텍처 리뷰 (Feature-Sliced Design)

FSD 아키텍처 준수 여부를 검증한다. FSD 구조가 아닌 프로젝트는 이 단계를 건너뛴다.

## FSD 감지

아래 디렉토리 중 2개 이상 존재하면 FSD 프로젝트로 판단:
- `app/`, `pages/` (또는 `views/`), `widgets/`, `features/`, `entities/`, `shared/`
- `src/app/`, `src/pages/` (또는 `src/views/`), `src/widgets/`, `src/features/`, `src/entities/`, `src/shared/`

> `app/` (또는 `src/app/`)만 있어도 레이어 책임 검사는 실행된다.

> 파일 기반 라우팅 프레임워크(Next.js, Nuxt 등)에서는 `pages/`가 프레임워크에 예약되어 있다. 이런 프로젝트에서는 FSD의 pages 레이어를 `views/`로 명명한다. `pages/`에 대한 모든 규칙은 `views/`에도 동일하게 적용된다.

## FSD 6개 레이어 (상위 → 하위)

```
app        ← 최상위: 라우팅, 프로바이더, 글로벌 설정
pages/views ← 페이지 단위 조합 (프레임워크가 pages/를 예약한 경우 views/)
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
app → pages(views) → widgets → features → entities → shared
              ↘          ↘         ↘          ↘
               shared     shared    shared     shared
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
| 페이지 로딩용 데이터 조합 | `pages/*/api` (또는 `views/*/api`) | `views/dashboard/model/loadDashboard.ts` |

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

### 레이어 책임

- [ ] `app/` 라우트 컴포넌트가 라우팅·프로바이더·글로벌 설정 외의 코드(UI 정의, 비즈니스 로직)를 포함하지 않는가?
- [ ] `pages/` (또는 `views/`) 컴포넌트가 하위 레이어 슬라이스를 조합만 하고, 직접 UI·로직을 구현하지 않는가?
- [ ] 컴포넌트 합성(여러 UI 블록 조합)이 `widgets/` 또는 `pages/views`에 있는가? (`app/`에 있으면 위반)
- [ ] 사용자 인터랙션 로직(form 처리, mutation, 이벤트 핸들러)이 `features/` 레이어에 있는가?
- [ ] 도메인 엔티티 표현(카드, 리스트, 데이터 모델)이 `entities/` 레이어에 있는가?

**판정 기준**:

| 레이어 | 허용되는 코드 | 위반 (하위 레이어로 내려야 하는 코드) |
|--------|-------------|--------------------------------------|
| `app/` | 라우팅 설정, 프로바이더 래핑, 글로벌 레이아웃 | UI 컴포넌트 정의, 비즈니스 로직, API 호출, form 처리, 도메인 엔티티 표현 |
| `pages/` (`views/`) | 하위 레이어 슬라이스 import & 조합, 페이지 레이아웃 | 조합 외 자체적인 UI 컴포넌트·로직 정의, 직접적인 API 호출 |
| `widgets/` | entities + features를 조합한 독립 UI 블록 | 직접적인 API 호출, 비즈니스 로직 구현, 도메인 엔티티 정의 |

**위반 예시와 해결 방법**:

| 위반 | 코드 | 해결 방법 |
|------|------|----------|
| `app/`에 UI 조합 | `app/routes/home.tsx`에서 `<Header>`, `<Sidebar>`, `<Feed>`를 인라인 정의 | 위젯으로 분리 (예: `widgets/home-layout`) 하거나 `pages/home`으로 이동 |
| `app/`에 인터랙션 로직 | `app/routes/login.tsx`에서 form 제출 처리, login API 호출, 로딩 상태 관리 | `features/auth`로 이동 — `features/auth/ui/LoginForm.tsx` 생성 |
| `app/` 또는 `pages/views`에 엔티티 표현 | `views/profile/ui/index.tsx`에서 `<UserAvatar>`, `<UserStats>`를 인라인 정의 | `entities/user/ui/`로 이동 후 import하여 사용 |

**코드 예시**:

```typescript
// ❌ app/ 라우트에 UI와 로직이 전부 포함된 경우
// app/routes/dashboard.tsx
export default function DashboardPage() {
  const [posts, setPosts] = useState([])
  useEffect(() => {
    fetch('/api/posts').then(r => r.json()).then(setPosts)
  }, [])

  return (
    <div>
      <nav>
        <a href="/">홈</a>
        <a href="/settings">설정</a>
      </nav>
      <main>
        {posts.map(post => (
          <div key={post.id}>
            <img src={post.author.avatar} />
            <h2>{post.title}</h2>
            <p>{post.body}</p>
          </div>
        ))}
      </main>
    </div>
  )
}

// ✅ 레이어별로 올바르게 분리된 경우
// entities/post/ui/PostCard.tsx  ← 엔티티 표현
// features/post-feed/ui/PostFeed.tsx  ← 데이터 로딩 + 목록 렌더링
// widgets/dashboard-layout/ui/DashboardLayout.tsx  ← 레이아웃 조합
// views/dashboard/ui/index.tsx  ← widgets/features 조합 (프레임워크가 pages/를 예약하지 않으면 pages/)
export default function DashboardPage() {
  return (
    <DashboardLayout>
      <PostFeed />
    </DashboardLayout>
  )
}
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
| `app/` 라우트에 하위 레이어 코드 포함 | ⚠️ WARNING |
| `pages/`(`views/`)에서 직접 UI/로직 구현 | ⚠️ WARNING |
| `widgets/`에서 API 호출 또는 비즈니스 로직 | ⚠️ WARNING |

> 아키텍처 위반은 모두 WARNING으로 처리한다. 자동 수정하지 않고 review 문서에 경고와 해결 방향을 함께 남긴다.
