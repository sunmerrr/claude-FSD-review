---
name: FSD-review
description: A review skill dedicated to FSD (Feature-Sliced Design) based frontend projects. Runs 9 review stages in parallel and generates a review report. Plugin architecture allows selecting only the reviews you need.
argument-hint: [--only ci,architecture] [--skip test]
---

# /FSD-review - FSD Frontend Review

Verifies FSD (Feature-Sliced Design) based frontend code changes through 9 review stages and generates a report. Does not modify code — only documents review results.

## Review Stages

```
① CI/CD (rule-based)        — tsc, lint, build, audit
② Architecture (FSD)        — layer violations, dependency direction
③ Code Quality              — checklist + clean code + React anti-patterns
④ Design System Compliance  — token usage, component consistency
⑤ Web Quality               — accessibility, performance, SEO automated checks
⑥ Security                  — XSS, CSRF, sensitive data, dependencies
⑦ Testing                   — test execution + quality verification
⑧ Deps/Deploy Safety        — new library review, compatibility, migration
⑨ Simplification/Maintainability — complexity, duplication, "can it be simpler?"
```

## Step 1: Project Detection & Configuration

### 1-1. Project Type Detection

```bash
# Detect package manager
ls package.json yarn.lock pnpm-lock.yaml bun.lockb 2>/dev/null
```

Determine the run command based on the result:
- `yarn.lock` → `yarn`
- `pnpm-lock.yaml` → `pnpm`
- `bun.lockb` → `bun`
- Otherwise → `npm`

### 1-2. Collect Changed Files

```bash
# Detect base branch
git rev-parse --verify main 2>/dev/null || git rev-parse --verify master 2>/dev/null || git rev-parse --verify develop 2>/dev/null

# List changed files
git diff <base>...HEAD --name-only
git diff --name-only        # unstaged
git diff --staged --name-only  # staged
```

Save the list of changed files as `CHANGED_FILES`. All subsequent stages review **only the changed files**.

### 1-3. Review File Path

Review results are saved in the `.pipeline/review/` folder at the project root, named after the branch:

```bash
mkdir -p .pipeline/review
BRANCH=$(git rev-parse --abbrev-ref HEAD)
# Review file: .pipeline/review/{branch-name}-review.md
```

### 1-4. Argument Parsing

- `--only <stages>`: Run only the specified stages (comma-separated, e.g., `--only ci,security`)
- `--skip <stages>`: Skip the specified stages (e.g., `--skip test,web-quality`)

Stage name mapping:
| Alias | Stage |
|------|------|
| `ci` | ① CI/CD |
| `architecture` | ② Architecture |
| `code-quality` | ③ Code Quality |
| `design-system` | ④ Design System |
| `web-quality` | ⑤ Web Quality |
| `security` | ⑥ Security |
| `test` | ⑦ Testing |
| `deps` | ⑧ Deps/Deploy Safety |
| `simplify` | ⑨ Simplification/Maintainability |

---

## Step 2: Run Reviews (Parallel)

All stages are **executed in parallel simultaneously**. Detailed checklists for each stage are defined in individual files within the `references/` directory.

### Execution Flow

```
1. Step 1 complete (project detection, changed file collection)
2. Run all 9 stages in parallel simultaneously (using Agent tool)
   ├─ ① CI/CD
   ├─ ② Architecture
   ├─ ③ Code Quality
   ├─ ④ Design System
   ├─ ⑤ Web Quality
   ├─ ⑥ Security
   ├─ ⑦ Testing
   ├─ ⑧ Deps/Deploy Safety
   └─ ⑨ Simplification/Maintainability
3. Collect all results → compile report
```

Result verdicts for each stage:
- ✅ PASS — No issues
- ⚠️ WARNING — Warning items, recorded in the document
- ❌ FAIL — Critical issues, recorded in the document
- ⊘ SKIP — Skipped due to unmet conditions

All issues are only recorded in the review document. No code is modified.

### ① CI/CD (Rule-Based)

Execute according to the checklist in `references/ci.md`.

Run the actual commands and determine pass/fail:
```bash
# Type check
{pkg-manager} run typecheck  # or npx tsc --noEmit

# Linting
{pkg-manager} run lint  # or npx biome check . / npx eslint .

# Build
{pkg-manager} run build

# Security audit
npm audit --audit-level=high
```

If a command does not exist (not defined in scripts), mark the item as `⚠️ Script not found` and move on.

### ② Architecture (FSD)

Verify according to the checklist in `references/architecture.md`.

**Analyze import statements** in the changed files to:
- Verify dependency direction between layers (only upper → lower is allowed)
- Detect cross-layer imports
- Detect public API (index.ts) bypass access
- Confirm proper layer placement of business logic
- Check segment structure appropriateness

When violations are found, refer to the solutions in `references/architecture.md` and **include specific resolution directions in the report**. (Does not modify code)

> ⚠️ Projects that do not follow the FSD structure will automatically skip this stage (determined by the presence of `app/`, `pages/`, `widgets/`, `features/`, `entities/`, `shared/` directories).

### ③ Code Quality

Verify according to the checklist in `references/code-quality.md`.

Read the changed files and let AI evaluate:
- Frontend code review checklist (general, ES6/7, React, CSS)
- React anti-pattern detection (prop drilling, excessive state, useEffect abuse, etc.)
- Clean code standards (function size, naming, SoC, DRY)

### ④ Design System Compliance

Verify according to the checklist in `references/design-system.md`.

In the changed files:
- Detect hardcoded color values (`#fff`, `rgb(...)`, `hsl(...)`, etc. → check design token usage)
- Detect hardcoded font sizes and spacing values
- Detect custom-built components that duplicate design system components
- Variant/props rule consistency

> ⚠️ Projects without a design system will automatically skip this stage (determined by the presence of design token files or UI library directories).

### ⑤ Web Quality (Automatable Scope Only)

Verify according to the checklist in `references/web-quality.md`.

Read the changed files and let AI check **only items detectable at the code level**:

**Accessibility**:
- `eslint-plugin-jsx-a11y` rule violation patterns
- Missing `alt` on `img`, empty buttons, incorrect ARIA
- Hardcoded color contrast detection

**Performance**:
- Use of `lazy` on LCP images
- Images missing `width`/`height`
- Barrel imports of large libraries
- Unnecessary re-render patterns

**SEO**:
- Missing metadata in page components
- Direct use of `<img>` instead of `next/image`
- SSR/SSG strategy appropriateness

### ⑥ Security

Verify according to the checklist in `references/security.md`.

**Exhaustive scan** of the changed files:
- `dangerouslySetInnerHTML` usage → must be flagged
- `eval()`, `new Function()` usage detection
- `href="javascript:..."` patterns
- Direct DOM insertion of user input
- Whether `NEXT_PUBLIC_` environment variables contain API keys/secrets
- Patterns of storing tokens/secrets in LocalStorage
- XSS vulnerability patterns in third-party components

### ⑦ Testing

Verify according to the checklist in `references/test.md`.

```bash
# Run tests
{pkg-manager} run test  # or npx vitest run
```

If there is no test script or no test files, mark as `⚠️ No tests` and finish.

If tests exist, run them and also **review test code quality**:
- Behavior verification vs implementation detail testing
- No internal logic (if/for) inside tests
- Appropriate mock usage
- Edge case coverage

### ⑧ Deps/Deploy Safety

Verify according to the checklist in `references/deps.md`.

Analyze changed `package.json`, lock files, and import statements for:
- Maintenance status of newly added libraries (last update, weekly downloads, issue count)
- Duplicate functionality with existing libraries
- Breaking change check for major version upgrades
- Bundle size impact (warn on large library additions)
- Whether lock file changes are intentional

### ⑨ Simplification/Maintainability

Verify according to the checklist in `references/simplify.md`.

Read the changed files and let AI evaluate:
- "Can this be written more simply?" — unnecessary abstraction, excessive wrapping
- Are multiple concerns mixed in a single PR? (atomic change check)
- Over-engineering for the future (YAGNI violations)
- Duplicate implementation of the same logic
- Can complex conditionals/nesting be simplified?

---

## Step 3: Generate Review Report

After all stages are complete, generate the report following the format in `references/output-format.md`.

Save the report to `.pipeline/review/{branch-name}-review.md`.

---

## Step 4: Output Results

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  FSD Review Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ① CI/CD              — ✅ PASS / ❌ FAIL (N issues)
  ② Architecture       — ✅ PASS / ⚠️ WARNING (N warnings)
  ③ Code Quality       — ✅ PASS / ❌ FAIL (N issues)
  ④ Design System      — ✅ PASS / ⊘ SKIP (no design system)
  ⑤ Web Quality        — ✅ PASS / ⚠️ WARNING
  ⑥ Security           — ✅ PASS / ❌ FAIL
  ⑦ Testing            — ✅ PASS / ⊘ SKIP (no tests)
  ⑧ Deps/Deploy        — ✅ PASS / ⚠️ WARNING
  ⑨ Simplification     — ✅ PASS / ⚠️ WARNING

  📄 .pipeline/review/{branch-name}-review.md
```

---

## Rules

- Review only changed files — do not review the entire codebase
- All review results must be recorded in the review document
- **Do not modify code** — the purpose of this skill is to document review results
- Write review results in the language the user uses
- Specify file names, function names, and line numbers concretely
