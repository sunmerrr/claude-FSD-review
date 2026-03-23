# claude-FSD-review

[Claude Code](https://claude.com/claude-code) skill for reviewing [Feature-Sliced Design](https://feature-sliced.design/) frontend projects.

9-stage parallel review pipeline that checks CI/CD, architecture, code quality, design system compliance, web quality, security, testing, dependency safety, and simplification — then generates a review report without modifying your code.

## Review Stages

All stages run **in parallel** for faster results.

```
① CI/CD            — tsc, lint, build, audit
② Architecture     — FSD layer violations, dependency direction
③ Code Quality     — checklist + clean code + React anti-patterns
④ Design System    — token usage, component consistency
⑤ Web Quality      — accessibility, performance, SEO
⑥ Security         — XSS, CSRF, secrets, dependencies
⑦ Testing          — test execution + test code quality
⑧ Dependencies     — new library review, compatibility, bundle size
⑨ Simplification   — complexity, duplication, YAGNI
```

## Installation

### As Claude Code Plugin (recommended)

```bash
claude plugin add sunmerrr/claude-FSD-review
```

### Manual Installation

```bash
git clone https://github.com/sunmerrr/claude-FSD-review.git
cd claude-FSD-review
./install.sh
```

## Usage

In your FSD project directory:

```bash
# Full review (all 9 stages)
/FSD-review

# Run specific stages only
/FSD-review --only ci,security

# Skip specific stages
/FSD-review --skip test,web-quality
```

Review reports are saved to `.review/{branch-name}-review.md`.

## Stages Detail

| Stage | What it does | Auto-skip condition |
|-------|-------------|---------------------|
| ① CI/CD | Runs tsc, lint, build, audit | Skips missing scripts |
| ② Architecture | Validates FSD layer imports | Skips if not FSD project |
| ③ Code Quality | React anti-patterns, clean code | — |
| ④ Design System | Hardcoded values, component reuse | Skips if no design system |
| ⑤ Web Quality | a11y, performance, SEO patterns | SEO skips for non-SSR |
| ⑥ Security | XSS, CSRF, secrets, deps | — |
| ⑦ Testing | Run tests + review test quality | Skips if no test files |
| ⑧ Dependencies | New library health, duplicates, breaking changes | Skips if no dependency changes |
| ⑨ Simplification | Complexity, duplication, YAGNI | — |

## Stage Name Mapping

For `--only` and `--skip` arguments:

| Alias | Stage |
|-------|-------|
| `ci` | ① CI/CD |
| `architecture` | ② Architecture |
| `code-quality` | ③ Code Quality |
| `design-system` | ④ Design System |
| `web-quality` | ⑤ Web Quality |
| `security` | ⑥ Security |
| `test` | ⑦ Testing |
| `deps` | ⑧ Dependencies |
| `simplify` | ⑨ Simplification |

## Using Checklists Without Claude Code

The review checklists in `skills/FSD-review/references/` are AI-agnostic markdown files. You can use them as:

- **Manual PR review checklists** for your team
- **Prompts for other AI tools** (paste the checklist content)
- **CI integration** (the CI checklist maps to GitHub Actions steps)

| File | Content |
|------|---------|
| `ci.md` | Type check, lint, build, audit rules |
| `architecture.md` | FSD layer dependency rules |
| `code-quality.md` | Frontend code review + React anti-patterns |
| `design-system.md` | Design token & component compliance |
| `web-quality.md` | Accessibility, performance, SEO checks |
| `security.md` | XSS, CSRF, secrets, dependency audit |
| `test.md` | Test execution + test code quality |
| `deps.md` | New library review, version compatibility, bundle size |
| `simplify.md` | Complexity, duplication, YAGNI, readability |
| `output-format.md` | Review report output template |

## Uninstall

```bash
./install.sh --uninstall
```

## Inspiration

Parallel subagent review architecture inspired by [Code Reviews with Claude Sub-Agents](https://hamy.xyz/blog/2026-02_code-reviews-claude-subagents).

## License

MIT
