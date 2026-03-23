---
name: FSD-review
description: FSD(Feature-Sliced Design) 기반 프론트엔드 프로젝트 전용 리뷰 스킬. 9개 리뷰 단계를 병렬 실행하고 리뷰 리포트를 생성한다. 플러그인 구조로 필요한 리뷰만 선택 가능.
argument-hint: [--only ci,architecture] [--skip test]
---

# /FSD-review - FSD 프론트엔드 리뷰

FSD(Feature-Sliced Design) 기반 프론트엔드 코드 변경사항을 9개 리뷰 단계로 검증하고 리포트를 생성한다. 코드를 수정하지 않는다 — 리뷰 결과만 문서로 남긴다.

## 리뷰 단계

```
① CI/CD (규칙 기반)     — tsc, lint, build, audit
② 아키텍처 (FSD)        — 레이어 위반, 의존성 방향
③ 코드 품질             — 체크리스트 + 클린코드 + React 안티패턴
④ 디자인 시스템 준수     — 토큰 사용, 컴포넌트 일관성
⑤ 웹 품질               — 접근성·성능·SEO 자동화 검사
⑥ 보안                  — XSS, CSRF, 민감 데이터, 의존성
⑦ 테스트                — 테스트 코드 실행 + 품질 검증
⑧ 의존성/배포 안전성     — 새 라이브러리 검토, 호환성, 마이그레이션
⑨ 단순화/유지보수성      — 복잡도, 중복, "더 간단할 수 없나?"
```

## Step 1: 프로젝트 감지 & 설정

### 1-1. 프로젝트 타입 감지

```bash
# 패키지 매니저 감지
ls package.json yarn.lock pnpm-lock.yaml bun.lockb 2>/dev/null
```

결과로 실행 명령어를 결정한다:
- `yarn.lock` → `yarn`
- `pnpm-lock.yaml` → `pnpm`
- `bun.lockb` → `bun`
- 그 외 → `npm`

### 1-2. 변경 파일 수집

```bash
# base 브랜치 감지
git rev-parse --verify main 2>/dev/null || git rev-parse --verify master 2>/dev/null || git rev-parse --verify develop 2>/dev/null

# 변경된 파일 목록
git diff <base>...HEAD --name-only
git diff --name-only        # unstaged
git diff --staged --name-only  # staged
```

변경된 파일 목록을 `CHANGED_FILES`로 저장. 이후 모든 단계에서 **변경된 파일만** 대상으로 리뷰한다.

### 1-3. 리뷰 파일 경로

리뷰 결과는 프로젝트 루트의 `.review/` 폴더에 브랜치 이름으로 저장한다:

```bash
mkdir -p .review
BRANCH=$(git rev-parse --abbrev-ref HEAD)
# 리뷰 파일: .review/{branch-name}-review.md
```

### 1-4. 인자 파싱

- `--only <stages>`: 지정된 단계만 실행 (쉼표 구분, 예: `--only ci,security`)
- `--skip <stages>`: 지정된 단계 건너뛰기 (예: `--skip test,web-quality`)

단계 이름 매핑:
| 약칭 | 단계 |
|------|------|
| `ci` | ① CI/CD |
| `architecture` | ② 아키텍처 |
| `code-quality` | ③ 코드 품질 |
| `design-system` | ④ 디자인 시스템 |
| `web-quality` | ⑤ 웹 품질 |
| `security` | ⑥ 보안 |
| `test` | ⑦ 테스트 |
| `deps` | ⑧ 의존성/배포 안전성 |
| `simplify` | ⑨ 단순화/유지보수성 |

---

## Step 2: 리뷰 실행 (병렬)

모든 단계를 **병렬로 동시 실행**한다. 단계별 상세 체크리스트는 `references/` 디렉토리의 개별 파일에 정의되어 있다.

### 실행 흐름

```
1. Step 1 완료 (프로젝트 감지, 변경 파일 수집)
2. 9개 단계를 동시에 병렬 실행 (Agent tool 사용)
   ├─ ① CI/CD
   ├─ ② 아키텍처
   ├─ ③ 코드 품질
   ├─ ④ 디자인 시스템
   ├─ ⑤ 웹 품질
   ├─ ⑥ 보안
   ├─ ⑦ 테스트
   ├─ ⑧ 의존성/배포 안전성
   └─ ⑨ 단순화/유지보수성
3. 모든 결과 수집 → 리포트 종합
```

각 단계의 결과 판정:
- ✅ PASS — 이슈 없음
- ⚠️ WARNING — 경고 사항, 문서에 기록
- ❌ FAIL — 심각한 이슈, 문서에 기록
- ⊘ SKIP — 조건 미충족으로 건너뜀

모든 이슈는 리뷰 문서에 기록만 한다. 코드를 수정하지 않는다.

### ① CI/CD (규칙 기반)

`references/ci.md`의 체크리스트에 따라 실행.

실제 명령어를 실행하고 pass/fail을 판정한다:
```bash
# 타입 체크
{pkg-manager} run typecheck  # 또는 npx tsc --noEmit

# 린팅
{pkg-manager} run lint  # 또는 npx biome check . / npx eslint .

# 빌드
{pkg-manager} run build

# 보안 감사
npm audit --audit-level=high
```

각 명령어가 없으면 (scripts에 미정의) 해당 항목은 `⚠️ 스크립트 없음`으로 표시하고 넘어간다.

### ② 아키텍처 (FSD)

`references/architecture.md`의 체크리스트에 따라 검증.

변경된 파일들의 **import 구문을 분석**하여:
- 레이어 간 의존성 방향 검증 (상위 → 하위만 허용)
- 크로스 레이어 import 감지
- public API(index.ts) 우회 접근 감지
- 비즈니스 로직의 적절한 레이어 배치 확인

> ⚠️ FSD 구조가 아닌 프로젝트는 이 단계를 자동 건너뛴다 (`app/`, `pages/`, `widgets/`, `features/`, `entities/`, `shared/` 디렉토리 존재 여부로 판단).

### ③ 코드 품질

`references/code-quality.md`의 체크리스트에 따라 검증.

변경된 파일을 읽고 AI가 판단:
- 프론트엔드 코드 리뷰 체크리스트 (일반, ES6/7, React, CSS)
- React 안티패턴 감지 (prop drilling, 과도한 state, useEffect 남용 등)
- 클린코드 기준 (함수 크기, 네이밍, SoC, DRY)

### ④ 디자인 시스템 준수

`references/design-system.md`의 체크리스트에 따라 검증.

변경된 파일에서:
- 하드코딩된 색상값 감지 (`#fff`, `rgb(...)`, `hsl(...)` 등 → 디자인 토큰 사용 여부)
- 하드코딩된 폰트 사이즈, 간격값 감지
- 디자인 시스템 컴포넌트 대신 직접 만든 유사 컴포넌트 감지
- variant/props 규칙 일관성

> ⚠️ 디자인 시스템이 없는 프로젝트는 이 단계를 자동 건너뛴다 (디자인 토큰 파일 또는 UI 라이브러리 디렉토리 존재 여부로 판단).

### ⑤ 웹 품질 (자동화 가능 범위만)

`references/web-quality.md`의 체크리스트에 따라 검증.

변경된 파일을 읽고 AI가 **코드 레벨에서 감지 가능한 항목만** 체크:

**접근성**:
- `eslint-plugin-jsx-a11y` 규칙 위반 패턴
- `img`에 `alt` 누락, 빈 버튼, 잘못된 ARIA
- 색상 대비 관련 하드코딩 감지

**성능**:
- LCP 이미지에 `lazy` 사용 여부
- `width`/`height` 누락 이미지
- 대형 라이브러리 barrel import
- 불필요한 리렌더 패턴

**SEO**:
- 페이지 컴포넌트에 메타데이터 누락
- `next/image` 대신 `<img>` 직접 사용
- SSR/SSG 전략 적절성

### ⑥ 보안

`references/security.md`의 체크리스트에 따라 검증.

변경된 파일에서 **전수 검사**:
- `dangerouslySetInnerHTML` 사용 → 반드시 플래그
- `eval()`, `new Function()` 사용 감지
- `href="javascript:..."` 패턴
- 사용자 입력의 DOM 직접 삽입
- `NEXT_PUBLIC_` 환경변수에 API 키/시크릿 포함 여부
- LocalStorage에 토큰/시크릿 저장 패턴
- 서드파티 컴포넌트 XSS 취약점 패턴

### ⑦ 테스트

`references/test.md`의 체크리스트에 따라 검증.

```bash
# 테스트 실행
{pkg-manager} run test  # 또는 npx vitest run
```

테스트 스크립트가 없거나 테스트 파일이 없으면 `⚠️ 테스트 없음`으로 표시하고 종료.

테스트가 존재하면 실행 후 **테스트 코드 품질도 리뷰**:
- 동작(behavior) 검증 vs 구현 세부사항 테스트
- 테스트 내부 로직(if/for) 없는가
- mock 사용 적절성
- 엣지 케이스 커버리지

### ⑧ 의존성/배포 안전성

`references/deps.md`의 체크리스트에 따라 검증.

변경된 `package.json`, lock 파일, import 구문을 분석하여:
- 새로 추가된 라이브러리의 유지보수 상태 (마지막 업데이트, 주간 다운로드, 이슈 수)
- 기존 라이브러리와 중복 기능 여부
- 메이저 버전 업그레이드 시 breaking change 확인
- 번들 사이즈 영향 (대형 라이브러리 추가 시 경고)
- lock 파일 변경이 의도된 것인지 확인

### ⑨ 단순화/유지보수성

`references/simplify.md`의 체크리스트에 따라 검증.

변경된 파일을 읽고 AI가 판단:
- "더 간단하게 작성할 수 없는가?" — 불필요한 추상화, 과도한 래핑
- 한 PR에 여러 관심사가 섞여있지 않은가 (원자적 변경 여부)
- 미래를 위한 과설계 (YAGNI 위반)
- 같은 로직의 중복 구현
- 복잡한 조건문/중첩이 단순화 가능한가

---

## Step 3: 리뷰 리포트 생성

모든 단계 완료 후, `references/output-format.md`의 형식에 따라 리포트를 생성한다.

리포트를 `.review/{branch-name}-review.md`에 저장한다.

---

## Step 4: 결과 출력

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  FSD Review Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ① CI/CD          — ✅ PASS / ❌ FAIL (N개 이슈)
  ② 아키텍처       — ✅ PASS / ⚠️ WARNING (N개 경고)
  ③ 코드 품질      — ✅ PASS / ❌ FAIL (N개 이슈)
  ④ 디자인 시스템   — ✅ PASS / ⊘ SKIP (디자인 시스템 없음)
  ⑤ 웹 품질        — ✅ PASS / ⚠️ WARNING
  ⑥ 보안           — ✅ PASS / ❌ FAIL
  ⑦ 테스트         — ✅ PASS / ⊘ SKIP (테스트 없음)
  ⑧ 의존성/배포    — ✅ PASS / ⚠️ WARNING
  ⑨ 단순화         — ✅ PASS / ⚠️ WARNING

  📄 .review/{branch-name}-review.md
```

---

## Rules

- 변경된 파일만 리뷰한다 — 전체 코드베이스를 리뷰하지 않는다
- 모든 리뷰 결과는 반드시 review 문서에 기록한다
- **코드를 수정하지 않는다** — 리뷰 결과를 문서로 남기는 것이 이 스킬의 목적이다
- 리뷰 결과는 사용자가 사용하는 언어로 작성한다
- 파일명, 함수명, 라인 번호를 구체적으로 명시한다
