# ⑤ Web Quality Review (Accessibility + Performance + SEO)

Only check items that can be automatically detected at the code level. Does not include Lighthouse runs or browser testing.

## Accessibility (A11y)

### Items Detectable from Code
- [ ] Missing `alt` attribute on `<img>`
- [ ] Empty buttons/links (`<button></button>`, `<a></a>`)
- [ ] Missing `href` on `<a>` tags
- [ ] Incorrect ARIA attribute usage (`aria-*` typos, wrong role)
- [ ] Skipped heading order (`h1` → `h3`)
- [ ] Usage of `tabIndex` > 0 (accessibility anti-pattern)
- [ ] Missing `label` association on form elements
- [ ] Non-interactive elements with click events but no keyboard events

## Performance

### Items Detectable from Code
- [ ] Using `loading="lazy"` on LCP candidate images (lazy on in-viewport images is an anti-pattern)
- [ ] Missing `width`/`height` or `aspect-ratio` on images (causes CLS)
- [ ] Barrel imports from large libraries (`import { x } from 'lodash'` → `import x from 'lodash/x'`)
- [ ] Unnecessary state updates inside `useEffect` (causes re-renders)
- [ ] Passing objects/functions to children without `useMemo`/`useCallback` (new reference on every render)
- [ ] Not using dynamic imports (statically importing large components)
- [ ] Using `<img>` directly instead of `next/image` (Next.js projects)

## SEO (Next.js/SSR Projects)

### Items Detectable from Code
- [ ] Missing `metadata` export or `<Head>` in page components
- [ ] Missing Open Graph / Twitter Card meta tags
- [ ] `canonical` URL not set
- [ ] Using `<img>` instead of `next/image` (including missing alt text)
- [ ] Missing `noindex` on CSR-only pages

> Skip SEO items for SPA projects that are not SSR/SSG frameworks.

## Severity Criteria

| Issue | Severity |
|------|--------|
| Missing `alt`, empty buttons/links | ❌ FAIL |
| ARIA errors, heading order | ❌ FAIL |
| Missing image width/height | ⚠️ WARNING |
| Barrel imports | ⚠️ WARNING |
| Lazy image misuse | ⚠️ WARNING |
| Missing metadata | ⚠️ WARNING |
| Direct `<img>` usage (Next.js) | ⚠️ WARNING |
