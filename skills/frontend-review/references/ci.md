# ① CI/CD Rule-Based Checks

Rule-based checks that can be run locally. Determined as pass/fail.

## Check Items

### Type Check
```bash
{pkg-manager} run typecheck  # or npx tsc --noEmit
```
- If there is even one type error ❌ FAIL
- If `tsconfig.json` does not exist ⊘ SKIP

### Linting
```bash
{pkg-manager} run lint  # or npx biome check . / npx eslint .
```
- If there are lint errors ❌ FAIL (warnings are ⚠️)
- Auto-fixable errors are subject to automatic correction

### Build
```bash
{pkg-manager} run build
```
- If build fails ❌ FAIL
- If build script does not exist ⊘ SKIP

### Security Audit
```bash
npm audit --audit-level=high
```
- If there are high/critical vulnerabilities ❌ FAIL
- Moderate or below are ⚠️ WARNING

## Judgment Criteria

| Item | PASS | FAIL | SKIP |
|------|------|------|------|
| Type Check | 0 errors | 1+ errors | No tsconfig |
| Linting | 0 errors | 1+ errors | No lint script |
| Build | Success | Failure | No build script |
| Security Audit | 0 high/critical | 1+ high/critical | — |

If even one item is FAIL, this stage is ❌ FAIL.
