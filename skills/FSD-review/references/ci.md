# ① CI/CD 규칙 기반 검사

로컬에서 실행 가능한 규칙 기반 검사. pass/fail로 판정한다.

## 검사 항목

### 타입 체크
```bash
{pkg-manager} run typecheck  # 또는 npx tsc --noEmit
```
- 타입 에러가 하나라도 있으면 ❌ FAIL
- `tsconfig.json`이 없으면 ⊘ SKIP

### 린팅
```bash
{pkg-manager} run lint  # 또는 npx biome check . / npx eslint .
```
- lint 에러가 있으면 ❌ FAIL (warning은 ⚠️)
- auto-fix 가능한 에러는 자동 수정 대상

### 빌드
```bash
{pkg-manager} run build
```
- 빌드 실패 시 ❌ FAIL
- build 스크립트가 없으면 ⊘ SKIP

### 보안 감사
```bash
npm audit --audit-level=high
```
- high/critical 취약점이 있으면 ❌ FAIL
- moderate 이하는 ⚠️ WARNING

## 판정 기준

| 항목 | PASS | FAIL | SKIP |
|------|------|------|------|
| 타입 체크 | 에러 0 | 에러 1+ | tsconfig 없음 |
| 린팅 | 에러 0 | 에러 1+ | lint 스크립트 없음 |
| 빌드 | 성공 | 실패 | build 스크립트 없음 |
| 보안 감사 | high/critical 0 | high/critical 1+ | — |

하나라도 FAIL이면 이 단계는 ❌ FAIL.
