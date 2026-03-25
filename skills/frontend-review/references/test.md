# ⑦ Test Review

Run tests and also review the quality of the test code.

## Test Execution

```bash
{pkg-manager} run test  # or npx vitest run / npx jest
```

- If there is no test script or no test files, `⊘ SKIP (no tests)` → end
- If tests fail, ❌ FAIL (include list of failed tests)
- If all tests pass → proceed to test code quality review

## Test Code Quality Checklist

Target test files (`*.test.*`, `*.spec.*`) related to the changed files:

### Test Design
- [ ] Do tests verify **behavior**? (not implementation details)
  - Bad: `expect(component.state.count).toBe(1)`
  - Good: `expect(screen.getByText('1')).toBeInTheDocument()`
- [ ] Are test names descriptive?
  - Bad: `it('works')`
  - Good: `it('submits the form when the user clicks the submit button')`
- [ ] Does each test verify only one concern?

### Test Implementation
- [ ] No logic (if/for/switch) inside tests?
- [ ] Are mocks used only for external dependencies? (no mocking internal implementations)
- [ ] Proper waiting in async tests (`waitFor`, `findBy`)
- [ ] No waiting with `setTimeout`? (causes flaky tests)

### Coverage
- [ ] Edge cases covered (empty arrays, null, undefined, long strings, special characters)
- [ ] Error scenarios tested (network errors, validation failures, etc.)
- [ ] Both happy path and sad path covered

## Severity Criteria

| Issue | Severity |
|------|--------|
| Test execution failure | ❌ FAIL |
| Testing implementation details | ⚠️ WARNING |
| Logic in tests (if/for) | ⚠️ WARNING |
| setTimeout waiting | ⚠️ WARNING |
| Mocking internal implementations | ⚠️ WARNING |
| Missing edge case coverage | ⚠️ WARNING |

> Test code quality issues are treated as WARNING. Only test execution failures are FAIL.
