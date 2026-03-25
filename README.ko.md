# claude-FSD-review

![status](https://img.shields.io/badge/status-beta-yellow) ![license](https://img.shields.io/badge/license-MIT-blue)

[Claude Code](https://claude.com/claude-code) 기반 프론트엔드 종합 코드 리뷰 플러그인 + [FSD](https://fsd.how/) 아키텍처 검증.

9개 리뷰 단계를 병렬 실행하여 CI/CD, FSD 아키텍처, 코드 품질, 디자인 시스템, 웹 품질, 보안, 테스트, 의존성, 단순화를 검토합니다. FSD 레이어/의존성 검증이 핵심 단계입니다. 코드를 수정하지 않고 리뷰 리포트를 생성합니다.

## 리뷰 단계

모든 단계가 **병렬로 동시 실행**됩니다.

```
① CI/CD            — tsc, lint, build, audit
② 아키텍처         — FSD 레이어 위반, 의존성 방향
③ 코드 품질        — 체크리스트 + 클린코드 + React 안티패턴
④ 디자인 시스템     — 토큰 사용, 컴포넌트 일관성
⑤ 웹 품질          — 접근성, 성능, SEO
⑥ 보안             — XSS, CSRF, 시크릿, 의존성
⑦ 테스트           — 테스트 실행 + 테스트 코드 품질
⑧ 의존성           — 새 라이브러리 검토, 호환성, 번들 사이즈
⑨ 단순화           — 복잡도, 중복, YAGNI
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
# 전체 리뷰 (9개 단계 모두)
/FSD-review

# 특정 단계만 실행
/FSD-review --only ci,security

# 특정 단계 건너뛰기
/FSD-review --skip test,web-quality
```

리뷰 리포트는 `.review/{branch-name}-review.md`에 저장됩니다.

## 단계 상세

| 단계 | 하는 일 | 자동 스킵 조건 |
|------|---------|---------------|
| ① CI/CD | tsc, lint, build, audit 실행 | 스크립트 없으면 스킵 |
| ② 아키텍처 | FSD 레이어 import 검증 | FSD 프로젝트가 아니면 스킵 |
| ③ 코드 품질 | 클린코드, ES6+, React 안티패턴 | React 프로젝트가 아니면 React 체크 스킵 |
| ④ 디자인 시스템 | 하드코딩 값, 컴포넌트 재사용 | 디자인 시스템 없으면 스킵 |
| ⑤ 웹 품질 | 접근성, 성능, SEO 패턴 | SSR 아니면 SEO 스킵 |
| ⑥ 보안 | XSS, CSRF, 시크릿, 의존성 | — |
| ⑦ 테스트 | 테스트 실행 + 테스트 코드 품질 리뷰 | 테스트 파일 없으면 스킵 |
| ⑧ 의존성 | 새 라이브러리 건전성, 중복, breaking changes | 의존성 변경 없으면 스킵 |
| ⑨ 단순화 | 복잡도, 중복, YAGNI | — |

## 단계 이름 매핑

`--only`와 `--skip` 인자용:

| 약칭 | 단계 |
|------|------|
| `ci` | ① CI/CD |
| `architecture` | ② 아키텍처 |
| `code-quality` | ③ 코드 품질 |
| `design-system` | ④ 디자인 시스템 |
| `web-quality` | ⑤ 웹 품질 |
| `security` | ⑥ 보안 |
| `test` | ⑦ 테스트 |
| `deps` | ⑧ 의존성 |
| `simplify` | ⑨ 단순화 |

## Claude Code 없이 체크리스트 사용하기

`skills/frontend-review/references/` 안의 리뷰 체크리스트는 AI에 종속되지 않는 마크다운 파일입니다. 다음과 같이 활용할 수 있습니다:

- **팀 PR 리뷰 체크리스트**로 수동 사용
- **다른 AI 도구의 프롬프트**로 사용 (체크리스트 내용을 붙여넣기)
- **CI 통합** (CI 체크리스트는 GitHub Actions 단계에 매핑 가능)

| 파일 | 내용 |
|------|------|
| `ci.md` | 타입 체크, 린트, 빌드, 감사 규칙 |
| `architecture.md` | FSD 레이어 의존성 규칙 |
| `code-quality.md` | 프론트엔드 코드 리뷰 + React 안티패턴 |
| `design-system.md` | 디자인 토큰 & 컴포넌트 준수 |
| `web-quality.md` | 접근성, 성능, SEO 체크 |
| `security.md` | XSS, CSRF, 시크릿, 의존성 감사 |
| `test.md` | 테스트 실행 + 테스트 코드 품질 |
| `deps.md` | 새 라이브러리 검토, 버전 호환성, 번들 사이즈 |
| `simplify.md` | 복잡도, 중복, YAGNI, 가독성 |
| `output-format.md` | 리뷰 리포트 출력 템플릿 |

## 제거

```bash
./install.sh --uninstall
```

## 영감

병렬 서브에이전트 리뷰 아키텍처는 [Code Reviews with Claude Sub-Agents](https://hamy.xyz/blog/2026-02_code-reviews-claude-subagents)에서 영감을 받았습니다.

## 라이선스

MIT
