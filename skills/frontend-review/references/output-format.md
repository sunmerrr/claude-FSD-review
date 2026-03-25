# FSD Review Output Format

Format for the review result report.

---

## Review Summary

> Review target: {number of changed files} files, branch `{branch-name}`

| Step | Result | Issues |
|------|------|------|
| ① CI/CD | ✅/❌/⊘ | N |
| ② Architecture | ✅/⚠️/⊘ | N |
| ③ Code Quality | ✅/❌ | N |
| ④ Design System | ✅/❌/⊘ | N |
| ⑤ Web Quality | ✅/⚠️ | N |
| ⑥ Security | ✅/❌ | N |
| ⑦ Tests | ✅/❌/⊘ | N |
| ⑧ Dependencies/Deployment | ✅/⚠️/⊘ | N |
| ⑨ Simplification | ✅/⚠️ | N |

---

## Step Details

### ① CI/CD

| Item | Result | Details |
|------|------|------|
| Type Check | ✅/❌/⊘ | (summary on error) |
| Linting | ✅/❌/⊘ | (number of errors) |
| Build | ✅/❌/⊘ | (summary on error) |
| Security Audit | ✅/❌ | (number of vulnerabilities) |

### ② Architecture

> If not FSD structure: `⊘ SKIP — Not FSD structure`

- (List of layer violations and dependency direction issues)
- Each issue includes filename:line

### ③ Code Quality

**Anti-pattern Detection**:
| File | Line | Anti-pattern | Severity | Description |
|------|------|---------|--------|------|
| `path/file.tsx` | 42 | Prop Drilling | ❌ | Description |

**Code Review Issues**:
- (Specific issue list, including file:line)

### ④ Design System

> If no design system: `⊘ SKIP — Design system not detected`

- (List of issues such as hardcoded values, unused components, etc.)

### ⑤ Web Quality

**Accessibility**:
- (Issue list)

**Performance**:
- (Issue list)

**SEO**:
- (Issue list, omit if not an SSR project)

### ⑥ Security

| File | Line | Threat | Severity | Description |
|------|------|------|--------|------|
| `path/file.tsx` | 15 | XSS | ❌ | `dangerouslySetInnerHTML` without sanitization |

### ⑦ Tests

| Item | Result | Details |
|------|------|------|
| Test Execution | ✅ N passed / ❌ N failed / ⊘ None | (list on failure) |
| Test Quality | ⚠️ N warnings | (warning list) |

---

## Notes

- Omit the detail section for steps with no issues
- Always specify file names, function names, and line numbers concretely
- Write the review results in the language used by the user
