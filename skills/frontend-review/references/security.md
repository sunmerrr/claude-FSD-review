# ⑥ Security Review

Perform a thorough inspection of all changed files.

## XSS (Cross-Site Scripting)

- [ ] Usage of `dangerouslySetInnerHTML` → **must flag** (check for DOMPurify wrapping)
- [ ] Usage of `eval()` → **immediate FAIL**
- [ ] Usage of `new Function()` → **immediate FAIL**
- [ ] `href="javascript:..."` pattern → **immediate FAIL**
- [ ] Usage of `document.write()` → **immediate FAIL**
- [ ] Is user input directly inserted into the DOM? (`innerHTML`, `outerHTML`)
- [ ] Are URL parameters used in rendering? (check input validation)
- [ ] XSS vulnerability patterns in third-party components (editors, markdown renderers)

## CSRF (Cross-Site Request Forgery)

- [ ] CSRF tokens or SameSite cookies used for state-changing API requests
- [ ] HttpOnly/Secure flags set on cookies

## Sensitive Data

- [ ] Detect patterns of storing tokens, passwords, or API keys in LocalStorage/SessionStorage
  - `localStorage.setItem('token', ...)`, `sessionStorage.setItem('secret', ...)`
- [ ] Are `.env` values exposed to the client?
  - Next.js: Check whether `NEXT_PUBLIC_` prefixed environment variables contain API keys/secrets
  - Vite: Check `VITE_` prefixed environment variables
- [ ] Hardcoded API keys, secrets, or passwords

## Dependencies

- [ ] `npm audit --audit-level=high` passes (overlaps with CI step, but also included in security report)
- [ ] Check for usage of known vulnerable libraries

## Severity Criteria

| Issue | Severity |
|------|--------|
| `eval()`, `new Function()`, `javascript:` href | ❌ FAIL (immediate) |
| `dangerouslySetInnerHTML` (without DOMPurify) | ❌ FAIL |
| `dangerouslySetInnerHTML` (with DOMPurify) | ⚠️ WARNING (noted in review) |
| `document.write()`, direct `innerHTML` usage | ❌ FAIL |
| Tokens/secrets stored in LocalStorage | ❌ FAIL |
| API keys in `NEXT_PUBLIC_`/`VITE_` | ❌ FAIL |
| Hardcoded secrets | ❌ FAIL |
| Missing CSRF tokens | ⚠️ WARNING |
| Dependencies with high/critical vulnerabilities | ❌ FAIL |

> Security issues are judged with the strictest criteria. FAIL items should be flagged with 🚩 for user confirmation rather than auto-fixed.
