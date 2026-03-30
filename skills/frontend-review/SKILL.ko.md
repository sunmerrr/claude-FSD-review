---
name: FSD-review
description: FSD(Feature-Sliced Design) 아키텍처 리뷰 — 레이어 의존성, 세그먼트 책임, 슬라이스 복잡도를 검증한다. 코드를 수정하지 않고 리뷰 리포트를 생성한다.
argument-hint: [--only architecture,code-quality] [--skip simplify]
---

# /FSD-review - FSD 아키텍처 리뷰

FSD(Feature-Sliced Design) 아키텍처 준수를 3개 리뷰 단계로 검증하고 리포트를 생성한다. 코드를 수정하지 않는다 — 리뷰 결과만 문서로 남긴다.

## 리뷰 단계

```
① 아키텍처 (FSD)          — 레이어 위반, 의존성 방향, Public API
② 코드 품질 (FSD 맥락)     — 세그먼트 책임, FSD 구조 내 안티패턴
③ 단순화                   — 슬라이스/세그먼트 복잡도, 크로스 슬라이스 중복
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

리뷰 결과는 프로젝트 루트의 `.pipeline/review/` 폴더에 브랜치 이름으로 저장한다:

```bash
mkdir -p .pipeline/review
BRANCH=$(git rev-parse --abbrev-ref HEAD)
# 리뷰 파일: .pipeline/review/{branch-name}-review.md
```

### 1-4. 인자 파싱

- `--only <stages>`: 지정된 단계만 실행 (쉼표 구분, 예: `--only architecture,code-quality`)
- `--skip <stages>`: 지정된 단계 건너뛰기 (예: `--skip simplify`)

단계 이름 매핑:
| 약칭 | 단계 |
|------|------|
| `architecture` | ① 아키텍처 |
| `code-quality` | ② 코드 품질 |
| `simplify` | ③ 단순화 |

---

## Step 2: 리뷰 실행 (병렬)

모든 단계를 **병렬로 동시 실행**한다. 단계별 상세 체크리스트는 `references/` 디렉토리의 개별 파일에 정의되어 있다.

### 실행 흐름

```
1. Step 1 완료 (프로젝트 감지, 변경 파일 수집)
2. 3개 단계를 동시에 병렬 실행 (Agent tool 사용)
   ├─ ① 아키텍처
   ├─ ② 코드 품질
   └─ ③ 단순화
3. 모든 결과 수집 → 리포트 종합
```

각 단계의 결과 판정:
- ✅ PASS — 이슈 없음
- ⚠️ WARNING — 경고 사항, 문서에 기록
- ❌ FAIL — 심각한 이슈, 문서에 기록
- ⊘ SKIP — 조건 미충족으로 건너뜀

모든 이슈는 리뷰 문서에 기록만 한다. 코드를 수정하지 않는다.

### ① 아키텍처 (FSD)

`references/architecture.md`의 체크리스트에 따라 검증.

변경된 파일들의 **import 구문을 분석**하여:
- 레이어 간 의존성 방향 검증 (상위 → 하위만 허용)
- 크로스 레이어 import 감지
- public API(index.ts) 우회 접근 감지
- 비즈니스 로직의 적절한 레이어 배치 확인
- 세그먼트 구조 적절성 확인

위반 발견 시 `references/architecture.md`의 해결책을 참고하여 **구체적인 해결 방향을 리포트에 포함**한다. (코드를 수정하지는 않는다)

> ⚠️ FSD 구조가 아닌 프로젝트는 이 단계를 자동 건너뛴다 (`app/`, `pages/`, `widgets/`, `features/`, `entities/`, `shared/` 디렉토리 존재 여부로 판단).

### ② 코드 품질 (FSD 맥락)

`references/code-quality.md`의 체크리스트에 따라 검증.

변경된 파일을 읽고 **FSD 구조 관점에서** 판단:
- FSD 세그먼트 책임 준수 (ui/에 비즈니스 로직 없는지, model/에 UI 코드 없는지 등)
- 슬라이스 데이터 흐름 패턴 (적절한 조합 vs 직접 크로스 슬라이스 import)
- React 안티패턴 감지 (prop drilling, 과도한 state, useEffect 남용 등)
- 일반 코드 품질 (ES6+, 클린코드, CSS)

### ③ 단순화

`references/simplify.md`의 체크리스트에 따라 검증.

변경된 파일을 읽고 **슬라이스/세그먼트 복잡도**를 판단:
- 과도한 슬라이싱: 자체 폴더를 정당화하기 어려운 사소한 슬라이스
- 과소 슬라이싱: 관련 없는 여러 도메인을 처리하는 슬라이스
- 크로스 슬라이스 중복: 여러 슬라이스에 같은 로직 반복 → 하위 레이어로 추출
- 일반 복잡도: 중첩 조건문, YAGNI, 가독성

---

## Step 3: 리뷰 리포트 생성

모든 단계 완료 후, `references/output-format.md`의 형식에 따라 리포트를 생성한다.

리포트를 `.pipeline/review/{branch-name}-review.md`에 저장한다.

---

## Step 4: 결과 출력

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  FSD Review Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ① 아키텍처       — ✅ PASS / ⚠️ WARNING (N개 경고)
  ② 코드 품질      — ✅ PASS / ❌ FAIL (N개 이슈)
  ③ 단순화         — ✅ PASS / ⚠️ WARNING

  📄 .pipeline/review/{branch-name}-review.md
```

---

## Rules

- 변경된 파일만 리뷰한다 — 전체 코드베이스를 리뷰하지 않는다
- 모든 리뷰 결과는 반드시 review 문서에 기록한다
- **코드를 수정하지 않는다** — 리뷰 결과를 문서로 남기는 것이 이 스킬의 목적이다
- 리뷰 결과는 사용자가 사용하는 언어로 작성한다
- 파일명, 함수명, 라인 번호를 구체적으로 명시한다
