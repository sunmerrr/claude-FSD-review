# ④ Design System Compliance Check

In projects with a design system, verify that the changed code correctly uses the design system.

## Design System Detection

If any of the following exist, the project is considered to have a design system:
- Design token files: `tokens.ts`, `theme.ts`, `variables.css`, `design-tokens.*`
- UI library directories: `shared/ui/`, `components/ui/`, `design-system/`
- Theme configuration: custom theme in `tailwind.config.*`, `styled-components` theme

If not detected, ⊘ SKIP.

## Checklist

### Design Token Usage

- [ ] No hardcoded color values? (`#fff`, `rgb(...)`, `hsl(...)` → use tokens)
- [ ] No hardcoded font sizes? (`14px`, `1.2rem` → use tokens)
- [ ] No hardcoded spacing values? (`8px`, `16px` → use tokens)
- [ ] No hardcoded border-radius? → use tokens
- [ ] No hardcoded shadow? → use tokens

> Tailwind projects: Check whether custom values defined in `tailwind.config` are being used. Warn if arbitrary values (`text-[14px]`) are repeated.

### Component Consistency

- [ ] Not reimplementing a component that already exists in the design system?
  - e.g., Using `<button className="...">` directly when `shared/ui/Button` exists
- [ ] Using design system component variants/props correctly?
- [ ] No excessive custom style overrides? (If too many overrides, suggest adding a variant)

## Severity Criteria

| Issue | Severity |
|------|--------|
| Hardcoded color/font/spacing (1–2 instances) | ⚠️ WARNING |
| Hardcoded color/font/spacing (3+ instances) | ❌ FAIL |
| Reimplementing instead of using existing component | ❌ FAIL |
| Excessive style overrides | ⚠️ WARNING |
| Repeated Tailwind arbitrary values (3+ times) | ⚠️ WARNING |
