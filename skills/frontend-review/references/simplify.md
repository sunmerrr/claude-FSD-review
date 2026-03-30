# ③ Simplification/Maintainability (FSD Context)

Verify that changed code is not more complex than necessary **within the FSD slice/segment structure**. Core question: **"Can this be written more simply while respecting FSD boundaries?"**

## FSD Slice Complexity Checklist

> Core question: **"Is this slice/segment appropriately scoped?"**

### Over-slicing
- [ ] Is a slice too small to justify its own folder? (e.g., a single component with no model/api)
- [ ] Are there multiple slices that always change together? → Consider merging into one slice
- [ ] Is a segment nearly empty? (e.g., `model/` with a single one-line hook) → May not need its own segment

### Under-slicing
- [ ] Does a single slice handle multiple unrelated business domains? → Consider splitting
- [ ] Is a slice's `model/` managing state for conceptually different concerns? → Split into separate slices
- [ ] Does a file exceed 300 lines within a slice? → Check if the slice has too many responsibilities

### Cross-slice Duplication
- [ ] Is the same logic duplicated across multiple slices? → Extract to lower layer (entities or shared)
- [ ] Do multiple features re-implement similar API call patterns? → Extract base to shared/api or entities/*/api
- [ ] Are similar UI patterns copied between slices? → Extract to shared/ui or entities/*/ui

**Examples**:

```
// ❌ Same validation logic duplicated in two features
features/checkout/lib/validateEmail.ts
features/auth/lib/validateEmail.ts

// ✅ Extract to shared
shared/lib/validation.ts  (or entities/user/lib/validateEmail.ts if domain-specific)
```

```
// ❌ Over-slicing — slice with only one tiny component
features/logout/
├── ui/
│   └── LogoutButton.tsx  (10 lines, just calls auth.logout())
└── index.ts

// ✅ This belongs in features/auth/ui/LogoutButton.tsx
```

## General Complexity Checklist

### Complexity
- [ ] Does each function/component have a single responsibility?
- [ ] Are there conditionals/callbacks nested 3+ levels deep? → Consider early return or extraction
- [ ] Are ternary operators nested? → Split into if/else or a separate function

### Over-engineering (YAGNI)
- [ ] Were parameters, options, or configurations added that are not currently used?
- [ ] Are there abstractions created "just in case they'll be needed later"?
- [ ] Was a utility/helper function used in only one place extracted into a separate file?
- [ ] Are generic types excessively complex? (relative to actual usage)

### Duplication
- [ ] Is the same logic repeated in 2+ places?
- [ ] Are there similar but slightly different components/functions? → Check if they can be consolidated

### Atomic Changes
- [ ] Does the PR contain unrelated changes mixed in?
- [ ] Are refactoring and feature changes in the same PR? → Recommend splitting

### Readability
- [ ] Do variable/function names clearly express intent?
- [ ] Are there magic numbers? → Extract to constants
- [ ] Is there code that cannot be understood without comments? → Improve the code itself to be clearer

## Severity Criteria

| Issue | Severity |
|------|--------|
| Same logic duplicated across 3+ slices | ❌ FAIL |
| Same logic duplicated in 2 slices | ⚠️ WARNING |
| Over-slicing (trivial slice) | ⚠️ WARNING |
| Under-slicing (slice with multiple domains) | ⚠️ WARNING |
| 3+ levels of nested conditionals/callbacks | ⚠️ WARNING |
| YAGNI violation (unused abstractions) | ⚠️ WARNING |
| Unrelated changes mixed in a PR | ⚠️ WARNING |
| Magic numbers | ⚠️ WARNING |
| 300+ line file | ⚠️ WARNING |
