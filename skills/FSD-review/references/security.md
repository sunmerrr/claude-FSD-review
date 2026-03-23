# ⑥ 보안 리뷰

변경된 모든 파일을 대상으로 전수 검사한다.

## XSS (Cross-Site Scripting)

- [ ] `dangerouslySetInnerHTML` 사용 여부 → **반드시 플래그** (DOMPurify 래핑 여부 확인)
- [ ] `eval()` 사용 → **즉시 FAIL**
- [ ] `new Function()` 사용 → **즉시 FAIL**
- [ ] `href="javascript:..."` 패턴 → **즉시 FAIL**
- [ ] `document.write()` 사용 → **즉시 FAIL**
- [ ] 사용자 입력이 DOM에 직접 삽입되는가? (`innerHTML`, `outerHTML`)
- [ ] URL 파라미터가 렌더링에 사용되는가? (입력 검증 확인)
- [ ] 서드파티 컴포넌트 (에디터, 마크다운 렌더러)의 XSS 취약점 패턴

## CSRF (Cross-Site Request Forgery)

- [ ] 상태 변경 API 요청에 CSRF 토큰 또는 SameSite 쿠키 사용
- [ ] 쿠키에 HttpOnly/Secure 플래그 설정

## 민감 데이터

- [ ] LocalStorage/SessionStorage에 토큰, 비밀번호, API 키 저장 패턴 감지
  - `localStorage.setItem('token', ...)`, `sessionStorage.setItem('secret', ...)`
- [ ] `.env` 값이 클라이언트에 노출되는가?
  - Next.js: `NEXT_PUBLIC_` 접두사 환경변수에 API 키/시크릿 포함 여부
  - Vite: `VITE_` 접두사 환경변수 확인
- [ ] 하드코딩된 API 키, 시크릿, 비밀번호

## 의존성

- [ ] `npm audit --audit-level=high` 통과 (CI 단계와 중복이지만 보안 리포트에도 포함)
- [ ] 알려진 취약 라이브러리 사용 여부

## 판정 기준

| 이슈 | 심각도 |
|------|--------|
| `eval()`, `new Function()`, `javascript:` href | ❌ FAIL (즉시) |
| `dangerouslySetInnerHTML` (DOMPurify 없이) | ❌ FAIL |
| `dangerouslySetInnerHTML` (DOMPurify 있음) | ⚠️ WARNING (리뷰 기록) |
| `document.write()`, `innerHTML` 직접 사용 | ❌ FAIL |
| LocalStorage에 토큰/시크릿 저장 | ❌ FAIL |
| `NEXT_PUBLIC_`/`VITE_`에 API 키 | ❌ FAIL |
| 하드코딩된 시크릿 | ❌ FAIL |
| CSRF 토큰 미사용 | ⚠️ WARNING |
| high/critical 취약점 의존성 | ❌ FAIL |

> 보안 이슈는 가장 엄격하게 판정한다. FAIL 항목은 자동 수정보다 🚩 플래그로 사용자 확인을 우선한다.
