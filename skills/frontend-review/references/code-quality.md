# ② Code Quality Review (FSD Context)

Read changed files and evaluate code quality **from the FSD structure perspective**. Focus on whether code within each segment/slice adheres to its intended responsibility.

## FSD Segment Responsibility Checklist

> Core question: **"Does the code in this segment belong here?"**

- [ ] `ui/` segment contains only presentational code — no API calls, no direct store mutation, no business logic
- [ ] `model/` segment contains only state and business logic — no DOM manipulation, no JSX, no style code
- [ ] `api/` segment contains only external communication — no UI rendering, no state management
- [ ] `lib/` segment contains only pure utilities — no side effects, no framework-specific code
- [ ] Component receives data via props/store, not by directly importing from upper layers

**Violation examples and solutions**:

```typescript
// ❌ Business logic in ui/ segment
// features/cart/ui/CartButton.tsx
function CartButton({ item }) {
  const discount = item.price > 100 ? item.price * 0.1 : 0  // business logic
  const finalPrice = item.price - discount                     // business logic
  return <button>{finalPrice}</button>
}

// ✅ Logic belongs in model/ or lib/
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
// ❌ UI code in model/ segment
// features/auth/model/useAuth.ts
export function useAuth() {
  const [user, setUser] = useState(null)
  document.title = user?.name ?? 'Guest'  // DOM manipulation in model
  return { user }
}

// ✅ Side effects belong in ui/ or handled via framework (e.g., useEffect in component)
```

## FSD Slice Data Flow Checklist

- [ ] Data between slices flows through proper FSD patterns (composition at higher layer, props, store) — not via direct cross-slice imports
- [ ] Shared state between features is lifted to entities or shared layer, not duplicated in each feature
- [ ] Slice does not expose internal implementation details beyond its public API

## General Checklist

- [ ] Is the code easy to understand?
- [ ] Does it match existing patterns/technologies?
- [ ] DRY — Is there no code duplicated more than once?
- [ ] Are function/class/component sizes reasonable?
- [ ] Are event listeners removed on teardown?
- [ ] Is Separation of Concerns (SoC) maintained?

## ES6+ Checklist

- [ ] `const` > `let` (no var)
- [ ] Use destructuring assignment
- [ ] Promise/Async-Await + proper rejection handling

## React Checklist

> Only applies when `react` is in `package.json`. Skip this section if it is not a React project.

- [ ] Is the component size reasonable? (under 200-300 lines, JSX under 50 lines)
- [ ] Use functional components for stateless logic
- [ ] No state updates inside loops
- [ ] Minimize logic inside render

## React Anti-pattern Detection

| Anti-pattern | Detection Method | Severity |
|---------|----------|--------|
| **Prop Drilling** | Pattern where the same prop is passed through 3+ levels | ❌ FAIL |
| **Direct state mutation** | `state.value = x` pattern | ❌ FAIL |
| **Excessive state** | Managing derivable values as state | ❌ FAIL |
| **Function recreation in render** | Inline event handler definition (when passed to children) | ⚠️ WARNING |
| **Data transformation in useEffect** | fetch + transform in a single useEffect | ⚠️ WARNING |
| **Storing derived state** | Using useState for `fullName = first + last` | ❌ FAIL |
| **Duplicate logic creation** | Function similar to an already existing utility | ⚠️ WARNING |

## CSS Checklist

- [ ] No use of `!important`
- [ ] No inline styles (use styled-components/CSS Modules)
- [ ] Animations use `transform`/`opacity` (instead of width/height/top/left)

## Severity Criteria

- ❌ If there is even one FAIL item, this stage is FAIL
- ⚠️ If there are only WARNINGs, it is PASS (warnings recorded)
