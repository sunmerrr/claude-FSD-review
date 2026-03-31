# ② Architecture Review (Feature-Sliced Design)

Verify compliance with FSD architecture. Skip this step for projects that do not follow the FSD structure.

## FSD Detection

If 2 or more of the following directories exist, the project is considered an FSD project:
- `app/`, `pages/` (or `views/`), `widgets/`, `features/`, `entities/`, `shared/`
- `src/app/`, `src/pages/` (or `src/views/`), `src/widgets/`, `src/features/`, `src/entities/`, `src/shared/`

> Even if only `app/` (or `src/app/`) is present, the Layer Responsibility check still applies.

> In frameworks with file-based routing (Next.js, Nuxt, etc.), `pages/` is reserved by the framework. In these projects, the FSD pages layer is typically named `views/`. All rules for `pages/` apply equally to `views/`.

## FSD 6 Layers (Top → Bottom)

```
app        ← Top level: routing, providers, global configuration
pages/views ← Page-level composition (views/ when framework reserves pages/)
widgets    ← Composed blocks combining entities + features
features   ← User actions/interactions (e.g., add-to-cart, login)
entities   ← Business objects and their representation (user, product)
shared     ← Bottom level: utilities, UI kit, types
```

## Checklist

### Dependency Direction (Core Rule)

- [ ] **Only top → bottom is allowed**: features can import entities and shared. entities cannot import features.
- [ ] **No imports between slices in the same layer**: If features/A directly imports features/B, it is a violation.

Allowed dependency directions:
```
app → pages(views) → widgets → features → entities → shared
              ↘          ↘         ↘          ↘
               shared     shared    shared     shared
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
| Data composition for page loading | `pages/*/api` (or `views/*/api`) | `views/dashboard/model/loadDashboard.ts` |

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

### Layer Responsibility

- [ ] Do `app/` route components contain only routing, providers, and global configuration — no UI component definitions or business logic?
- [ ] Do `pages/` (or `views/`) components only compose slices from lower layers, without directly implementing UI or logic?
- [ ] Is component composition (combining multiple UI blocks) placed in `widgets/` or `pages/views`, not in `app/`?
- [ ] Is user interaction logic (form handling, mutations, event handlers) placed in the `features/` layer?
- [ ] Are domain entity representations (cards, lists, data models) placed in the `entities/` layer?

**Detection criteria**:

| Layer | Allowed | Violation (should be moved to a lower layer) |
|-------|---------|----------------------------------------------|
| `app/` | Route configuration, provider wrapping, global layout | UI component definitions, business logic, API calls, form handling, domain entity representation |
| `pages/` (`views/`) | Import & compose lower-layer slices, page layout | Defining its own UI components or logic beyond composition, direct API calls |
| `widgets/` | Compose entities + features into independent UI blocks | Direct API calls, business logic implementation, domain entity definitions |

**Violation examples and solutions**:

| Violation | Code | Solution |
|-----------|------|----------|
| UI composition in `app/` | `app/routes/home.tsx` defines `<Header>`, `<Sidebar>`, `<Feed>` inline | Extract into a widget (e.g., `widgets/home-layout`) or move to `pages/home` |
| Interaction logic in `app/` | `app/routes/login.tsx` handles form submit, calls login API, manages loading state | Move to `features/auth` — create `features/auth/ui/LoginForm.tsx` |
| Entity representation in `app/` or `pages/views` | `views/profile/ui/index.tsx` defines `<UserAvatar>`, `<UserStats>` inline | Move to `entities/user/ui/` and import from there |

**Code example**:

```typescript
// ❌ All UI and logic packed into app/ route
// app/routes/dashboard.tsx
export default function DashboardPage() {
  const [posts, setPosts] = useState([])
  useEffect(() => {
    fetch('/api/posts').then(r => r.json()).then(setPosts)
  }, [])

  return (
    <div>
      <nav>
        <a href="/">Home</a>
        <a href="/settings">Settings</a>
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

// ✅ Properly separated by layer
// entities/post/ui/PostCard.tsx  ← entity representation
// features/post-feed/ui/PostFeed.tsx  ← data fetching + list rendering
// widgets/dashboard-layout/ui/DashboardLayout.tsx  ← layout composition
// views/dashboard/ui/index.tsx  ← composes widgets/features (or pages/ if no framework conflict)
export default function DashboardPage() {
  return (
    <DashboardLayout>
      <PostFeed />
    </DashboardLayout>
  )
}
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
| Lower-layer code in `app/` route components | ⚠️ WARNING |
| Direct UI/logic implementation in `pages/` (`views/`) | ⚠️ WARNING |
| API calls or business logic in `widgets/` | ⚠️ WARNING |

> All architecture violations are treated as WARNING. They are not auto-fixed; instead, warnings and suggested resolution directions are documented in the review.
