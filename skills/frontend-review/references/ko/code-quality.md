# ② 코드 품질 리뷰 (FSD 맥락)

변경된 파일을 읽고 **FSD 구조 관점에서** 코드 품질을 평가한다. 각 세그먼트/슬라이스 내 코드가 의도된 책임에 맞는지에 초점을 둔다.

## FSD 세그먼트 책임 체크리스트

> 핵심 질문: **"이 세그먼트에 이 코드가 있는 게 맞는가?"**

- [ ] `ui/` 세그먼트에는 표현 코드만 — API 호출, 직접 store 변경, 비즈니스 로직 없음
- [ ] `model/` 세그먼트에는 상태와 비즈니스 로직만 — DOM 조작, JSX, 스타일 코드 없음
- [ ] `api/` 세그먼트에는 외부 통신만 — UI 렌더링, 상태 관리 없음
- [ ] `lib/` 세그먼트에는 순수 유틸만 — 사이드 이펙트, 프레임워크 종속 코드 없음
- [ ] 컴포넌트가 props/store를 통해 데이터를 받으며, 상위 레이어에서 직접 import하지 않음

**위반 예시와 해결책**:

```typescript
// ❌ ui/ 세그먼트에 비즈니스 로직
// features/cart/ui/CartButton.tsx
function CartButton({ item }) {
  const discount = item.price > 100 ? item.price * 0.1 : 0  // 비즈니스 로직
  const finalPrice = item.price - discount                     // 비즈니스 로직
  return <button>{finalPrice}</button>
}

// ✅ 로직은 model/ 또는 lib/에
// features/cart/lib/calcPrice.ts
export function calcFinalPrice(price: number) {
  const discount = price > 100 ? price * 0.1 : 0
  return price - discount
}

// features/cart/ui/CartButton.tsx
import { calcFinalPrice } from '../lib/calcPrice'
function CartButton({ item }) {
  return <button>{calcFinalPrice(item.price)}</button>
}
```

```typescript
// ❌ model/ 세그먼트에 UI 코드
// features/auth/model/useAuth.ts
export function useAuth() {
  const [user, setUser] = useState(null)
  document.title = user?.name ?? 'Guest'  // model에서 DOM 조작
  return { user }
}

// ✅ 사이드 이펙트는 ui/에서 또는 프레임워크를 통해 처리 (예: 컴포넌트 내 useEffect)
```

## FSD 슬라이스 데이터 흐름 체크리스트

- [ ] 슬라이스 간 데이터는 올바른 FSD 패턴(상위 레이어에서 조합, props, store)으로 전달 — 직접 크로스 슬라이스 import 아님
- [ ] feature 간 공유 상태는 entities 또는 shared 레이어로 끌어올림 — 각 feature에 중복 없음
- [ ] 슬라이스가 public API 너머로 내부 구현 세부사항을 노출하지 않음

## 일반 체크리스트

- [ ] 코드가 쉽게 이해되는가?
- [ ] 기존 패턴/기술과 일치하는가?
- [ ] DRY — 2번 이상 중복된 코드 없는가?
- [ ] 함수/클래스/컴포넌트 크기가 합리적인가?
- [ ] 이벤트 리스너가 teardown 시 제거되는가?
- [ ] 관심사 분리(SoC)가 지켜지는가?

## ES6+ 체크리스트

- [ ] `const` > `let` (var 금지)
- [ ] 구조 분해 할당 사용
- [ ] Promise/Async-Await + 적절한 rejection 처리

## React 체크리스트

> `package.json`에 `react`가 있을 때만 적용. React 프로젝트가 아니면 이 섹션을 건너뛴다.

- [ ] 컴포넌트 크기 합리적인가? (200~300줄 이하, JSX 50줄 이하)
- [ ] 상태 없는 로직은 함수형 컴포넌트 사용
- [ ] 루프 내 state 업데이트 없음
- [ ] render 내 로직 최소화

## React 안티패턴 감지

| 안티패턴 | 감지 방법 | 심각도 |
|---------|----------|--------|
| **Prop Drilling** | 3단계 이상 같은 prop이 전달되는 패턴 | ❌ FAIL |
| **직접 state 변경** | `state.value = x` 패턴 | ❌ FAIL |
| **과도한 state** | 파생 가능한 값을 state로 관리 | ❌ FAIL |
| **render 내 함수 재생성** | 이벤트 핸들러 인라인 정의 (자식에 전달 시) | ⚠️ WARNING |
| **useEffect 내 데이터 변환** | fetch + transform이 하나의 useEffect에 | ⚠️ WARNING |
| **파생 state 저장** | `fullName = first + last`를 useState로 | ❌ FAIL |
| **중복 로직 생성** | 이미 존재하는 유틸과 유사한 함수 | ⚠️ WARNING |

## CSS 체크리스트

- [ ] `!important` 사용 안 함
- [ ] 인라인 스타일 사용 안 함 (스타일 컴포넌트/CSS Modules 사용)
- [ ] 애니메이션은 `transform`/`opacity` 사용 (width/height/top/left 대신)

## 판정 기준

- ❌ FAIL 항목이 하나라도 있으면 이 단계는 FAIL
- ⚠️ WARNING만 있으면 PASS (경고 기록)
