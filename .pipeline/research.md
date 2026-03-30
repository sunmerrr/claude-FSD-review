# Research: FSD-review 스코프 축소 (9개 → 3개 스테이지) 타당성 검증

## 핵심 질문

1. **이 방향이 FSD에 도움이 되는가?** — Architecture + Code Quality + Simplification 3개만 남기는 것
2. **타 도구들과 차별점을 유지하는가?**

---

## Web Research Findings

### FSD의 핵심 원칙과 관심사

FSD(Feature-Sliced Design)가 해결하려는 문제:
- **레이어 간 의존성 방향** — 상위 → 하위만 허용, 역방향/동일 레이어 import 금지
- **Public API를 통한 캡슐화** — 슬라이스 내부 파일 직접 접근 금지
- **비즈니스 로직 배치** — 적절한 레이어에 로직이 위치하는가
- **세그먼트 구조** — ui/model/api/lib/config 분리
- **느슨한 결합 + 높은 응집도** — 슬라이스 간 독립성, 슬라이스 내 관련 코드 밀집

FSD 공식 문서에 따르면 핵심 규칙은: "한 레이어의 모듈은 **엄격히 아래 레이어**의 모듈만 알고 import할 수 있다."

### 기존 FSD 도구: Steiger

[Steiger](https://github.com/feature-sliced/steiger)는 FSD 공식 린터로 **20개 규칙**을 검증한다:

| 카테고리 | 규칙 예시 | 검증 방식 |
|---------|----------|----------|
| Import 제한 | `forbidden-imports`, `no-public-api-sidestep` | 파일 구조 + import 경로 패턴 |
| 구조 무결성 | `no-segmentless-slices`, `no-ui-in-app` | 디렉토리 존재 여부 |
| 네이밍 | `inconsistent-naming`, `ambiguous-slice-names` | 폴더명 검사 |
| 복잡도 | `excessive-slicing`, `insignificant-slice` | 파일/참조 수 카운트 |

**Steiger가 하지 않는 것:**
- 코드 내용(비즈니스 로직, 안티패턴) 분석
- 코드 품질/클린코드 판단
- 단순화/유지보수성 평가
- FSD 맥락에서의 코드 리뷰 (import 경로만 볼 뿐, 코드가 올바른 레이어에 있는지 "내용"으로 판단하지 않음)

→ **Steiger는 구조/파일 레벨, FSD-review는 코드/의미 레벨** — 상호보완적

### AI 코드 리뷰 도구 현황 (2026)

| 도구 | 주요 초점 | FSD 지원 |
|------|----------|---------|
| [CodeRabbit](https://coderabbit.ai) | 범용 PR 리뷰, 40+ 린터 통합 | ❌ 없음 |
| [GitHub Copilot Code Review](https://github.com/features/copilot) | 버그, 타입오, null 체크 | ❌ 없음 (아키텍처 미지원) |
| [Greptile](https://greptile.com) | 코드베이스 전체 맥락 분석 | ❌ 없음 |
| [Qodo Merge](https://www.qodo.ai) | 엔터프라이즈, 테스트 생성 | ❌ 없음 |
| [SonarQube](https://www.sonarqube.org) | 정적 분석 6,500+ 규칙 | ❌ 없음 |
| [Anthropic Code Review](https://claude.com/plugins/code-review) | 5개 병렬 에이전트 PR 리뷰 | ❌ 없음 |

**핵심 발견: FSD 아키텍처를 이해하고 리뷰하는 AI 코드 리뷰 도구는 현재 존재하지 않는다.**

### Claude Code 플러그인 생태계

- 2026년 3월 기준 마켓플레이스에 101개 플러그인 (33 Anthropic + 68 파트너)
- Anthropic 공식 Code Review 플러그인은 범용 리뷰 (CLAUDE.md 준수, 버그, 히스토리, PR 코멘트)
- **아키텍처 특화 리뷰 플러그인은 거의 없음**

### Key References

- [FSD Overview](https://feature-sliced.design/docs/get-started/overview) — FSD 핵심 원칙과 레이어 구조
- [Steiger - GitHub](https://github.com/feature-sliced/steiger) — FSD 공식 린터, 20개 구조 규칙
- [Best AI Code Review Tools 2026](https://dev.to/heraldofsolace/the-best-ai-code-review-tools-of-2026-2mb3) — 주요 AI 리뷰 도구 비교, FSD 지원 없음
- [AI Code Review Comparison](https://www.verdent.ai/guides/best-ai-for-code-review-2026) — 도구별 갭 분석
- [Claude Code Review](https://claude.com/blog/code-review) — Anthropic 공식 코드 리뷰 기능

---

## Project Overview

- **Tech Stack**: Claude Code Plugin (마크다운 기반 스킬 정의)
- **Architecture**: 플러그인 구조 — SKILL.md가 실행 프롬프트, references/가 체크리스트
- **Directory Structure**:
  ```
  .claude-plugin/     ← 플러그인 메타데이터
  skills/frontend-review/
    SKILL.md           ← 영문 스킬 정의 (메인)
    SKILL.ko.md        ← 한국어 스킬 정의
    references/        ← 9개 체크리스트 (en)
    references/ko/     ← 9개 체크리스트 (ko)
  ```

---

## 남길 3개 스테이지의 FSD 관련성 분석

### ① Architecture (현재 ②)
- **FSD 관련성: ★★★★★ (핵심)**
- 레이어 의존성, Public API, 비즈니스 로직 배치, 세그먼트 구조
- Steiger가 파일/경로 수준에서 하는 것을 **코드 내용 수준**에서 보완

### ② Code Quality (현재 ③)
- **FSD 관련성: ★★★☆☆ → FSD 맥락 강화 시 ★★★★☆**
- 현재: 범용 코드 품질 (ES6+, React 안티패턴, CSS)
- **FSD 맥락 강화 가능**: 세그먼트 내 코드가 해당 세그먼트의 책임에 맞는지 (ui/에 비즈니스 로직, model/에 UI 코드 등)
- React 안티패턴 중 prop drilling은 FSD에서 특히 중요 (레이어를 통한 데이터 전달 vs 직접 import)

### ③ Simplification (현재 ⑨)
- **FSD 관련성: ★★★☆☆ → FSD 맥락 강화 시 ★★★★☆**
- 현재: 범용 복잡도/중복/YAGNI
- **FSD 맥락 강화 가능**: 불필요한 레이어 추상화, 과도한 슬라이스 분리, 한 슬라이스에서 다른 슬라이스와 중복되는 로직

---

## 제거할 6개 스테이지의 대체 도구

| 제거 스테이지 | 이미 잘 하는 도구들 |
|-------------|------------------|
| ① CI/CD | GitHub Actions, `tsc`, `eslint`, `biome` — 자동화가 이미 표준 |
| ④ Design System | Storybook, Chromatic, StyleLint — 디자인 시스템 전용 도구 |
| ⑤ Web Quality | Lighthouse, axe, eslint-plugin-jsx-a11y — 성숙한 생태계 |
| ⑥ Security | Snyk, CodeQL, npm audit, GitHub Dependabot — 전문 보안 도구 |
| ⑦ Testing | Vitest, Jest, Testing Library — 테스트 프레임워크 자체가 충분 |
| ⑧ Dependencies | Renovate, Dependabot, bundlephobia — 의존성 전문 도구 |

---

## 결론: 두 질문에 대한 답

### 1. 이 방향이 FSD에 도움이 되는가?

**예, 확실히 도움이 된다.**

남는 3개 스테이지가 FSD의 핵심 가치와 정확히 정렬된다:

| FSD 핵심 원칙 | 대응 스테이지 |
|-------------|------------|
| 레이어 의존성 방향 | ① Architecture |
| Public API 캡슐화 | ① Architecture |
| 비즈니스 로직 적절한 배치 | ① Architecture + ② Code Quality |
| 세그먼트 내 관심사 분리 | ② Code Quality |
| 느슨한 결합 / 높은 응집도 | ③ Simplification |
| 과도한 슬라이싱 방지 | ③ Simplification |

제거되는 6개(CI/CD, Design System, Web Quality, Security, Testing, Deps)는 FSD 아키텍처와 직접적 관련이 없는 범용 프론트엔드 품질 항목이다. 이것들이 있으면 "FSD review"가 아니라 "frontend review"가 된다.

또한 Steiger(공식 린터)와의 관계가 명확해진다:
- **Steiger** = 파일 구조/경로 수준의 FSD 검증 (자동화, CI에서 실행)
- **FSD-review** = 코드 내용/의미 수준의 FSD 검증 (AI 기반, PR 리뷰에서 실행)

### 2. 타 도구들과 차별점을 유지하는가?

**예, 오히려 차별점이 강화된다.**

| 도구 | 포지셔닝 |
|------|---------|
| CodeRabbit, Copilot 등 | 범용 AI 코드 리뷰 (FSD 모름) |
| Steiger | FSD 구조 린팅 (코드 내용 모름) |
| SonarQube, Snyk 등 | 정적 분석/보안 (아키텍처 모름) |
| **FSD-review (축소 후)** | **FSD 아키텍처 + 코드 의미 수준 리뷰 (유일무이)** |

9개 스테이지일 때는 CodeRabbit/Copilot과 6개 스테이지가 겹쳤다. 3개로 줄이면 **겹치는 도구가 없는 고유 영역**을 점유하게 된다.

### 추가 제안: Code Quality와 Simplification의 FSD 맥락 강화

스코프를 줄이면서 남는 두 스테이지를 FSD 맥락에 더 특화시키면 차별점이 극대화된다:

**Code Quality에 추가할 FSD 관점:**
- `ui/` 세그먼트에 비즈니스 로직이 섞여있지 않은가
- `model/`에서 UI 관련 코드(DOM 조작, 스타일 등)를 사용하지 않는가
- 슬라이스 간 데이터 전달이 FSD 패턴(composition, props, store)을 따르는가

**Simplification에 추가할 FSD 관점:**
- 하나의 슬라이스가 너무 많은 책임을 가지고 있지 않은가 (슬라이스 분리 필요)
- 반대로 너무 세분화된 슬라이스가 있지 않은가 (과도한 슬라이싱)
- 여러 슬라이스에 중복된 로직이 있다면 하위 레이어로 내릴 수 있지 않은가

이렇게 하면 3개 스테이지 모두 "FSD 관점의 리뷰"라는 일관된 정체성을 갖게 된다.
