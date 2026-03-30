# claude-FSD-review

![Claude Code Plugin](https://img.shields.io/badge/Claude_Code-Plugin-blueviolet) ![status](https://img.shields.io/badge/status-beta-yellow) ![license](https://img.shields.io/badge/license-MIT-blue)

[Claude Code](https://claude.com/claude-code) 기반 [FSD](https://fsd.how/) (Feature-Sliced Design) 아키텍처 리뷰 플러그인.

FSD 아키텍처에 집중하는 3단계 병렬 리뷰 파이프라인: 레이어 의존성 검증, 세그먼트 책임 준수, 슬라이스 복잡도 분석. [Steiger](https://github.com/feature-sliced/steiger)(파일 구조)가 커버하지 못하는 **코드 내용 수준**의 리뷰를 보완합니다. 코드를 수정하지 않고 리뷰 리포트를 생성합니다.

## 리뷰 단계

모든 단계가 **병렬로 동시 실행**됩니다.

```
① 아키텍처      — FSD 레이어 위반, 의존성 방향, Public API
② 코드 품질     — 세그먼트 책임, FSD 구조 내 안티패턴
③ 단순화        — 슬라이스/세그먼트 복잡도, 크로스 슬라이스 중복
```

## 설치

### Claude Code 플러그인 (권장)

```bash
# 1. 마켓플레이스 등록
claude plugin marketplace add sunmerrr/claude-FSD-review

# 2. 플러그인 설치
claude plugin install FSD-review@sunmerrr-FSD-review
```

### 수동 설치

```bash
git clone https://github.com/sunmerrr/claude-FSD-review.git
cd claude-FSD-review
./install.sh
```

## 사용법

FSD 프로젝트 디렉토리에서:

```bash
# 전체 리뷰 (3개 단계 모두)
/FSD-review

# 특정 단계만 실행
/FSD-review --only architecture,code-quality

# 특정 단계 건너뛰기
/FSD-review --skip simplify
```

리뷰 리포트는 `.pipeline/review/{branch-name}-review.md`에 저장됩니다.

## 단계 상세

| 단계 | 하는 일 | 자동 스킵 조건 |
|------|---------|---------------|
| ① 아키텍처 | FSD 레이어 import 검증, 의존성 방향, Public API 접근, 비즈니스 로직 배치 | FSD 프로젝트가 아니면 스킵 |
| ② 코드 품질 | 세그먼트 책임 검사 (ui/에 로직 없는지, model/에 UI 없는지), React 안티패턴, 데이터 흐름 | React 프로젝트가 아니면 React 체크 스킵 |
| ③ 단순화 | 과도한/과소 슬라이싱, 크로스 슬라이스 중복, 일반 복잡도 | — |

## 단계 이름 매핑

`--only`와 `--skip` 인자용:

| 약칭 | 단계 |
|------|------|
| `architecture` | ① 아키텍처 |
| `code-quality` | ② 코드 품질 |
| `simplify` | ③ 단순화 |

## Steiger와의 관계

| | [Steiger](https://github.com/feature-sliced/steiger) | FSD-review |
|--|---------|------------|
| **수준** | 파일 구조 / 경로 | 코드 내용 / 의미 |
| **검사** | 폴더 네이밍, import 경로, 디렉토리 규칙 | 세그먼트 책임, 슬라이스 복잡도, 안티패턴 |
| **시점** | CI / 실시간 린팅 | 온디맨드 (개발 중 또는 PR 리뷰 시) |
| **방식** | 정적 규칙 엔진 (20개 규칙) | AI 기반 맥락 분석 |

## Claude Code 없이 체크리스트 사용하기

`skills/frontend-review/references/` 안의 리뷰 체크리스트는 AI에 종속되지 않는 마크다운 파일입니다. 다음과 같이 활용할 수 있습니다:

- **팀 PR 리뷰 체크리스트**로 수동 사용
- **다른 AI 도구의 프롬프트**로 사용 (체크리스트 내용을 붙여넣기)

| 파일 | 내용 |
|------|------|
| `architecture.md` | FSD 레이어 의존성 규칙 |
| `code-quality.md` | 세그먼트 책임 + 코드 안티패턴 |
| `simplify.md` | 슬라이스 복잡도, 중복, YAGNI |
| `output-format.md` | 리뷰 리포트 출력 템플릿 |

## 제거

```bash
# 플러그인으로 설치한 경우
claude plugin uninstall FSD-review@sunmerrr-FSD-review

# 수동 설치한 경우
./install.sh --uninstall
```

## 영감

병렬 서브에이전트 리뷰 아키텍처는 [Code Reviews with Claude Sub-Agents](https://hamy.xyz/blog/2026-02_code-reviews-claude-subagents)에서 영감을 받았습니다.

## 라이선스

MIT
