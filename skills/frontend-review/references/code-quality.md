# ③ Code Quality Review

Read the changed files and let the AI judge.

## General Checklist

- [ ] Is the code easy to understand?
- [ ] Does it match existing patterns/technologies?
- [ ] DRY — Is there no code duplicated more than once?
- [ ] Are function/class/component sizes reasonable?
- [ ] Are event listeners removed on teardown?
- [ ] Is Separation of Concerns (SoC) maintained?

## ES6+ Checklist

- [ ] `const` > `let` (no var)
- [ ] Use destructuring assignment
- [ ] Promise/Async-Await + proper rejection handling

## React Checklist

> Only applies when `react` is in `package.json`. Skip this section if it is not a React project.

- [ ] Is the component size reasonable? (under 200–300 lines, JSX under 50 lines)
- [ ] Use functional components for stateless logic
- [ ] No state updates inside loops
- [ ] Minimize logic inside render

## React Anti-pattern Detection

| Anti-pattern | Detection Method | Severity |
|---------|----------|--------|
| **Prop Drilling** | Pattern where the same prop is passed through 3+ levels | ❌ FAIL |
| **Direct state mutation** | `state.value = x` pattern | ❌ FAIL |
| **Excessive state** | Managing derivable values as state | ❌ FAIL |
| **Function recreation in render** | Inline event handler definition (when passed to children) | ⚠️ WARNING |
| **Data transformation in useEffect** | fetch + transform in a single useEffect | ⚠️ WARNING |
| **Storing derived state** | Using useState for `fullName = first + last` | ❌ FAIL |
| **Duplicate logic creation** | Function similar to an already existing utility | ⚠️ WARNING |

## CSS Checklist

- [ ] No use of `!important`
- [ ] No inline styles (use styled-components/CSS Modules)
- [ ] Animations use `transform`/`opacity` (instead of width/height/top/left)

## Judgment Criteria

- ❌ If there is even one FAIL item, this stage is FAIL
- ⚠️ If there are only WARNINGs, it is PASS (warnings recorded)
