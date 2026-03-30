---
name: FSD-review
description: FSD (Feature-Sliced Design) architecture review — validates layer dependencies, segment responsibilities, and slice complexity. Generates a review report without modifying code.
argument-hint: [--only architecture,code-quality] [--skip simplify]
---

# /FSD-review - FSD Architecture Review

Verifies FSD (Feature-Sliced Design) architecture compliance through 3 review stages and generates a report. Does not modify code — only documents review results.

## Review Stages

```
① Architecture (FSD)        — layer violations, dependency direction, public API
② Code Quality (FSD Context) — segment responsibility, anti-patterns within FSD structure
③ Simplification            — slice/segment complexity, cross-slice duplication
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

- `--only <stages>`: Run only the specified stages (comma-separated, e.g., `--only architecture,code-quality`)
- `--skip <stages>`: Skip the specified stages (e.g., `--skip simplify`)

Stage name mapping:
| Alias | Stage |
|------|------|
| `architecture` | ① Architecture |
| `code-quality` | ② Code Quality |
| `simplify` | ③ Simplification |

---

## Step 2: Run Reviews (Parallel)

All stages are **executed in parallel simultaneously**. Detailed checklists for each stage are defined in individual files within the `references/` directory.

### Execution Flow

```
1. Step 1 complete (project detection, changed file collection)
2. Run all 3 stages in parallel simultaneously (using Agent tool)
   ├─ ① Architecture
   ├─ ② Code Quality
   └─ ③ Simplification
3. Collect all results → compile report
```

Result verdicts for each stage:
- ✅ PASS — No issues
- ⚠️ WARNING — Warning items, recorded in the document
- ❌ FAIL — Critical issues, recorded in the document
- ⊘ SKIP — Skipped due to unmet conditions

All issues are only recorded in the review document. No code is modified.

### ① Architecture (FSD)

Verify according to the checklist in `references/architecture.md`.

**Analyze import statements** in the changed files to:
- Verify dependency direction between layers (only upper → lower is allowed)
- Detect cross-layer imports
- Detect public API (index.ts) bypass access
- Confirm proper layer placement of business logic
- Check segment structure appropriateness

When violations are found, refer to the solutions in `references/architecture.md` and **include specific resolution directions in the report**. (Does not modify code)

> ⚠️ Projects that do not follow the FSD structure will automatically skip this stage (determined by the presence of `app/`, `pages/`, `widgets/`, `features/`, `entities/`, `shared/` directories).

### ② Code Quality (FSD Context)

Verify according to the checklist in `references/code-quality.md`.

Read the changed files and evaluate **from the FSD structure perspective**:
- FSD segment responsibility compliance (ui/ has no business logic, model/ has no UI code, etc.)
- Slice data flow patterns (proper composition vs direct cross-slice imports)
- React anti-pattern detection (prop drilling, excessive state, useEffect abuse, etc.)
- General code quality (ES6+, clean code, CSS)

### ③ Simplification

Verify according to the checklist in `references/simplify.md`.

Read the changed files and evaluate **slice/segment complexity**:
- Over-slicing: trivial slices that don't justify their own folder
- Under-slicing: slices handling multiple unrelated domains
- Cross-slice duplication: same logic repeated across slices → extract to lower layer
- General complexity: nested conditionals, YAGNI, readability

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

  ① Architecture       — ✅ PASS / ⚠️ WARNING (N warnings)
  ② Code Quality       — ✅ PASS / ❌ FAIL (N issues)
  ③ Simplification     — ✅ PASS / ⚠️ WARNING

  📄 .pipeline/review/{branch-name}-review.md
```

---

## Rules

- Review only changed files — do not review the entire codebase
- All review results must be recorded in the review document
- **Do not modify code** — the purpose of this skill is to document review results
- Write review results in the language the user uses
- Specify file names, function names, and line numbers concretely
