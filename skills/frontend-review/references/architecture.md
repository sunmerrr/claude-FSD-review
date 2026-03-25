# ② Architecture Review (Feature-Sliced Design)

Verify compliance with FSD architecture. Skip this step for projects that do not follow the FSD structure.

## FSD Detection

If 3 or more of the following directories exist, the project is considered an FSD project:
- `app/`, `pages/`, `widgets/`, `features/`, `entities/`, `shared/`
- `src/app/`, `src/pages/`, `src/widgets/`, `src/features/`, `src/entities/`, `src/shared/`

## FSD 6 Layers (Top → Bottom)

```
app        ← Top level: routing, providers, global configuration
pages      ← Page-level composition
widgets    ← Self-contained large functional blocks
features   ← Reusable product features
entities   ← Business entities (user, product)
shared     ← Bottom level: utilities, UI kit, types
```

## Checklist

### Dependency Direction (Core Rule)

- [ ] **Only top → bottom is allowed**: features can import entities and shared. entities cannot import features.
- [ ] **No imports between slices in the same layer**: If features/A directly imports features/B, it is a violation.

Allowed dependency directions:
```
app → pages → widgets → features → entities → shared
         ↘      ↘         ↘          ↘
          shared  shared    shared     shared
```

**Violation examples and solutions**:

| Violation | Code | Solution |
|-----------|------|----------|
| Reverse import | `entities/user` imports `features/auth` | Move shared logic down to `shared/`, or define the interface needed by `entities/user` and inject it from `features/auth` |
| Same-layer import | `features/cart` imports `features/product` | Move shared data down to `entities/`, or compose both features in a higher layer (widgets/pages) |
| shared → upper layer | `shared/api` imports type from `entities/user` | Define generic types in `shared/types`, and extend with concrete types in `entities/` |

### Public API Access

- [ ] Are internal files within a slice not accessed directly?
- [ ] Does each slice have an `index.ts` (barrel export)?

**Violation examples and solutions**:

```typescript
// ❌ Direct access to internal files
import { authStore } from 'features/auth/model/store'
import { UserCard } from 'entities/user/ui/UserCard'

// ✅ Access through public API
import { authStore } from 'features/auth'
import { UserCard } from 'entities/user'
```

When barrel exports are missing:
```typescript
// Create features/auth/index.ts
export { authStore } from './model/store'
export { LoginForm } from './ui/LoginForm'
// Selectively export only what should be exposed externally
```

### Business Logic Placement

- [ ] Are API calls placed in the appropriate layer?
- [ ] Is business logic not mixed into UI components?
- [ ] Does the shared layer not contain business logic?

**API call placement guidelines**:

| API Type | Placement Layer | Example |
|----------|----------------|---------|
| General-purpose HTTP client (axios wrapper, fetch config) | `shared/api` | `shared/api/client.ts` |
| Specific entity CRUD | `entities/*/api` | `entities/user/api/getUser.ts` |
| API tied to a business feature | `features/*/api` | `features/checkout/api/processPayment.ts` |
| Data composition for page loading | `pages/*/api` or `pages/*/model` | `pages/dashboard/model/loadDashboard.ts` |

**When business logic is mixed into UI**:

```typescript
// ❌ Business logic mixed in component
function OrderCard({ order }) {
  const discount = order.total > 100 ? order.total * 0.1 : 0  // business logic
  const finalPrice = order.total - discount                     // business logic
  return <div>{finalPrice}원</div>
}

// ✅ Logic separated
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

**When business logic exists in shared**:

```typescript
// ❌ Business logic in shared
// shared/lib/orderUtils.ts
export function isEligibleForDiscount(user, order) { ... }

// ✅ Business logic belongs in entities or above
// entities/order/lib/discount.ts
export function isEligibleForDiscount(user, order) { ... }
```

Decision criterion: "Does this logic need to know about a specific domain concept (user, order, product, etc.)?" → If yes, place it in entities or above, not in shared.

### Segment Structure

- [ ] Is each slice properly divided into appropriate segments?

**Standard segments**:

| Segment | Role | Contains |
|---------|------|----------|
| `ui/` | Display | Components, styles |
| `model/` | State & logic | Store, hooks, business logic |
| `api/` | External communication | API calls, request/response types |
| `lib/` | Utilities | Helper functions, constants, formatters |
| `config/` | Configuration | Environment settings, constant maps |

```
features/auth/
├── ui/          ← LoginForm, AuthButton
├── model/       ← authStore, useAuth
├── api/         ← login(), logout()
├── lib/         ← validatePassword()
└── index.ts     ← public API
```

## Severity Criteria

| Issue | Severity |
|-------|----------|
| Bottom → top import (reverse direction) | ⚠️ WARNING |
| Direct import between slices in the same layer | ⚠️ WARNING |
| Bypassing public API access | ⚠️ WARNING |
| Missing barrel export (index.ts) | ⚠️ WARNING |
| Business logic in shared | ⚠️ WARNING |
| Business logic mixed in UI components | ⚠️ WARNING |
| No segment separation (all code in a single file) | ⚠️ WARNING |

> All architecture violations are treated as WARNING. They are not auto-fixed; instead, warnings and suggested resolution directions are documented in the review.
