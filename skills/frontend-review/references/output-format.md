# FSD Review Output Format

Format for the review result report.

---

## Review Summary

> Review target: {number of changed files} files, branch `{branch-name}`

| Step | Result | Issues |
|------|------|------|
| ① Architecture | ✅/⚠️/⊘ | N |
| ② Code Quality | ✅/❌ | N |
| ③ Simplification | ✅/⚠️ | N |

---

## Step Details

### ① Architecture

> If not FSD structure: `⊘ SKIP — Not FSD structure`

- (List of layer violations and dependency direction issues)
- Each issue includes filename:line

### ② Code Quality

**FSD Segment Responsibility Issues**:
| File | Segment | Issue | Severity | Description |
|------|---------|-------|--------|------|
| `path/file.tsx` | `ui/` | Business logic in UI | ⚠️ | Description |

**Anti-pattern Detection**:
| File | Line | Anti-pattern | Severity | Description |
|------|------|---------|--------|------|
| `path/file.tsx` | 42 | Prop Drilling | ❌ | Description |

**Code Review Issues**:
- (Specific issue list, including file:line)

### ③ Simplification

**FSD Slice Complexity Issues**:
| File/Slice | Issue | Severity | Description |
|-----------|-------|--------|------|
| `features/logout/` | Over-slicing | ⚠️ | Description |

**General Complexity Issues**:
- (Specific issue list, including file:line)

---

## Notes

- Omit the detail section for steps with no issues
- Always specify file names, function names, and line numbers concretely
- Write the review results in the language used by the user
