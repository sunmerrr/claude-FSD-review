# claude-FSD-review

![Claude Code Plugin](https://img.shields.io/badge/Claude_Code-Plugin-blueviolet) ![status](https://img.shields.io/badge/status-beta-yellow) ![license](https://img.shields.io/badge/license-MIT-blue)

[Claude Code](https://claude.com/claude-code) plugin for [FSD](https://fsd.how/) (Feature-Sliced Design) architecture review.

3-stage parallel review pipeline focused on FSD architecture: layer dependency validation, segment responsibility compliance, and slice complexity analysis. Complements [Steiger](https://github.com/feature-sliced/steiger) (file structure) by reviewing at the **code content level**. Generates a review report without modifying your code.

## Review Stages

All stages run **in parallel** for faster results.

```
① Architecture      — FSD layer violations, dependency direction, public API
② Code Quality      — segment responsibility, anti-patterns within FSD structure
③ Simplification    — slice/segment complexity, cross-slice duplication
```

## Installation

### As Claude Code Plugin (recommended)

```bash
# 1. Add marketplace
claude plugin marketplace add sunmerrr/claude-FSD-review

# 2. Install plugin
claude plugin install FSD-review@sunmerrr-FSD-review
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
# Full review (all 3 stages)
/FSD-review

# Run specific stages only
/FSD-review --only architecture,code-quality

# Skip specific stages
/FSD-review --skip simplify
```

Review reports are saved to `.pipeline/review/{branch-name}-review.md`.

## Stages Detail

| Stage | What it does | Auto-skip condition |
|-------|-------------|---------------------|
| ① Architecture | Validates FSD layer imports, dependency direction, public API access, business logic placement | Skips if not FSD project |
| ② Code Quality | Checks segment responsibility (no logic in ui/, no UI in model/), React anti-patterns, data flow patterns | React checks skip if not React project |
| ③ Simplification | Detects over/under-slicing, cross-slice duplication, general complexity | — |

## Stage Name Mapping

For `--only` and `--skip` arguments:

| Alias | Stage |
|-------|-------|
| `architecture` | ① Architecture |
| `code-quality` | ② Code Quality |
| `simplify` | ③ Simplification |

## How It Complements Steiger

| | [Steiger](https://github.com/feature-sliced/steiger) | FSD-review |
|--|---------|------------|
| **Level** | File structure / path | Code content / semantics |
| **Checks** | Folder naming, import paths, directory rules | Segment responsibility, slice complexity, anti-patterns |
| **When** | CI / real-time linting | On-demand (during development or PR review) |
| **How** | Static rule engine (20 rules) | AI-based contextual analysis |

## Using Checklists Without Claude Code

The review checklists in `skills/frontend-review/references/` are AI-agnostic markdown files. You can use them as:

- **Manual PR review checklists** for your team
- **Prompts for other AI tools** (paste the checklist content)

| File | Content |
|------|---------|
| `architecture.md` | FSD layer dependency rules |
| `code-quality.md` | Segment responsibility + code anti-patterns |
| `simplify.md` | Slice complexity, duplication, YAGNI |
| `output-format.md` | Review report output template |

## Uninstall

```bash
# If installed as plugin
claude plugin uninstall FSD-review@sunmerrr-FSD-review

# If installed manually
./install.sh --uninstall
```

## Inspiration

Parallel subagent review architecture inspired by [Code Reviews with Claude Sub-Agents](https://hamy.xyz/blog/2026-02_code-reviews-claude-subagents).

## License

MIT
