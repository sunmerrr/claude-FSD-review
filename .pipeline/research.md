# Research: FSD 패턴 특화 리뷰 플러그인/스킬 존재 여부

## Web Research Findings

### 기존 도구 현황

FSD 생태계에는 다양한 도구가 있지만, **FSD 전용 코드 리뷰 도구는 아직 없다.**

| 영역 | 기존 도구 | 성격 |
|------|-----------|------|
| 파일 구조 린팅 | Steiger (공식) | 폴더/파일 구조만 검증, 코드 내용 분석 안 함 |
| ESLint 임포트 규칙 | 6개+ 플러그인 | import 경로, 레이어 의존성만 검사 |
| IDE 슬라이스 생성 | JetBrains Helper | 생성 도구, 리뷰 아님 |
| AI 스킬 (가이드) | constellos FSD Architect | 아키텍처 가이드/생성용, 코드 리뷰 아님 |
| **FSD 전용 코드 리뷰** | **없음** | **빈 공간** |

### Libraries & Tools

| Library | Purpose | Stars/Popularity | 유형 | Notes |
|---------|---------|-----------------|------|-------|
| `steiger` + `@feature-sliced/steiger-plugin` | FSD 파일 구조 린터 | 327 stars | 린터 | 공식 도구, 베타, 규칙 20개, 코드 내용은 분석 안 함 |
| `@feature-sliced/eslint-config` | FSD ESLint 설정 | 14K/주 다운로드 | ESLint | 공식, eslint-plugin-boundaries 기반 |
| `eslint-plugin-fsd-lint` | FSD ESLint 플러그인 | 60 stars | ESLint | ESLint 9+ Flat Config 지원, 규칙 7개 |
| `eslint-plugin-feature-sliced-design` | FSD 레이어/슬라이스 규칙 | npm 등재 | ESLint | 커뮤니티 |
| `@conarti/eslint-plugin-feature-sliced` | FSD ESLint 플러그인 | GitHub | ESLint | 베타 |
| constellos FSD Architect | FSD 아키텍처 가이드 스킬 | mcpmarket | Claude Code 스킬 | 생성/가이드 도구, 리뷰 아님 |

### Key References

- [Steiger - GitHub](https://github.com/feature-sliced/steiger) — FSD 공식 파일 구조 린터
- [@feature-sliced/eslint-config](https://github.com/feature-sliced/eslint-config) — FSD 공식 ESLint 설정
- [eslint-plugin-fsd-lint](https://github.com/effozen/eslint-plugin-fsd-lint) — ESLint 9+ 지원 FSD 린트 규칙
- [constellos FSD Architect - mcpmarket](https://mcpmarket.com/ko/tools/skills/feature-sliced-design-architect) — Claude Code용 FSD 아키텍처 가이드 스킬
- [Feature-Sliced Design Helper - JetBrains](https://plugins.jetbrains.com/plugin/21638-feature-sliced-design-helper) — JetBrains IDE용 슬라이스 생성기
- [Feature-Sliced Design 공식](https://feature-sliced.design/) — FSD 공식 문서

## Project Overview

- **Tech Stack**: Claude Code Skill (Markdown + Bash)
- **Architecture**: 9단계 병렬 리뷰 파이프라인
- **Directory Structure**: `skills/FSD-review/` (SKILL.md + references/)

신규 프로젝트 — 리뷰 대상 코드베이스 아님, 스킬 프로젝트 자체.

## 핵심 발견

### 경쟁 도구 없음

FSD에 특화된 **AI 코드 리뷰 도구는 현재 존재하지 않는다.** 기존 도구들의 한계:

1. **Steiger**: 파일/폴더 구조만 검증. "이 폴더가 FSD 규칙에 맞는가?"만 판단. 코드 내용(import 패턴, 비즈니스 로직 배치, 컴포넌트 설계)은 분석하지 않음.
2. **ESLint 플러그인들**: import 경로 규칙만 검사. "features에서 entities를 import했는가?" 수준. 코드 품질, 보안, 접근성, 디자인 시스템 준수는 범위 밖.
3. **constellos FSD Architect**: 코드 **생성/가이드** 도구. "FSD 구조로 슬라이스를 만들어줘" 용도. 기존 코드를 리뷰하지 않음.

### claude-FSD-review의 차별점

| 기존 도구 | claude-FSD-review |
|-----------|-------------------|
| 파일 구조만 검증 | 코드 내용까지 분석 |
| import 규칙만 | 9개 영역 종합 리뷰 |
| 단일 관심사 | CI/CD + 아키텍처 + 코드 품질 + 디자인 시스템 + 웹 품질 + 보안 + 테스트 + 의존성 + 단순화 |
| 실시간 린팅 | PR 단위 리뷰 리포트 생성 |
| 규칙 위반만 보고 | AI가 맥락 파악하여 개선 제안 |

### 홍보 포인트

1. **FSD 전용 AI 코드 리뷰는 세계 최초** — 이 포지셔닝 사용 가능
2. **Steiger + ESLint의 상위 호환** — 기존 린팅 도구가 커버하지 못하는 영역을 보완
3. **9개 영역 병렬 리뷰** — CI/CD, 아키텍처, 코드 품질, 디자인 시스템, 웹 품질, 보안, 테스트, 의존성, 단순화
4. **리포트 생성** — `.review/{branch}-review.md`로 팀 공유 가능
5. **플러그인 설치 한 줄** — `claude plugin add sunmerrr/claude-FSD-review`

### 홍보 가능 채널

| 채널 | URL | 적합도 |
|------|-----|--------|
| FSD 공식 GitHub Discussions | https://github.com/feature-sliced/documentation/discussions | 최적 타겟 |
| FSD 공식 Telegram | feature-sliced.design에서 링크 | FSD 사용자 집중 |
| Reddit r/reactjs | https://reddit.com/r/reactjs | React 개발자 대상 |
| Reddit r/frontend | https://reddit.com/r/frontend | 프론트엔드 전반 |
| Claude Code Discord/Community | Claude Code 사용자 대상 | 플러그인 사용자 |
| mcpmarket.com | https://mcpmarket.com | Claude Code 스킬 마켓 |
| claude-plugins.dev | https://claude-plugins.dev | Claude Code 플러그인 디렉토리 |

## Recommendation

**claude-FSD-review는 현재 FSD 생태계에서 유일한 AI 코드 리뷰 도구다.** 기존 도구들(Steiger, ESLint 플러그인)은 정적 분석에 한정되어 있고, AI 스킬(constellos)은 코드 생성/가이드 용도다. PR 단위로 FSD 프로젝트를 종합적으로 리뷰하는 도구는 존재하지 않으므로, 이 포지셔닝을 활용한 홍보가 효과적일 것이다.

FSD 공식 GitHub Discussions가 1순위 홍보 채널이며, mcpmarket.com과 claude-plugins.dev에도 등록하면 검색 노출에 유리하다.
