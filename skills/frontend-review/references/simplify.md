# ⑨ Simplification/Maintainability

Verify that the changed code is not more complex than necessary. Core question: **"Can this be written more simply?"**

## Checklist

### Complexity
- [ ] Does each function/component have a single responsibility?
- [ ] Are there conditionals/callbacks nested 3+ levels deep? → Consider early return or extraction
- [ ] Are ternary operators nested? → Split into if/else or a separate function
- [ ] Is a file longer than 300 lines? → Consider splitting

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
| 3+ levels of nested conditionals/callbacks | ⚠️ WARNING |
| YAGNI violation (unused abstractions) | ⚠️ WARNING |
| Same logic duplicated in 3+ places | ❌ FAIL |
| Same logic duplicated in 2 places | ⚠️ WARNING |
| Unrelated changes mixed in a PR | ⚠️ WARNING |
| Magic numbers | ⚠️ WARNING |
| 300+ line file | ⚠️ WARNING |
