# ⑧ Dependency/Deployment Safety

Verify the safety of newly added or changed dependencies.

## Detection Targets

- Changes to `dependencies`, `devDependencies` in `package.json`
- Changes to lock files (`yarn.lock`, `pnpm-lock.yaml`, `package-lock.json`)
- New `import`/`require` statements (packages not previously used)

> If there are no changes to `package.json` or lock files, and no new imports, ⊘ SKIP.

## Checklist

### When Adding a New Library
- [ ] Check maintenance status — warn if last update was more than 1 year ago
- [ ] Weekly download count — warn if extremely low (< 1,000/week)
- [ ] Feature overlap with existing dependencies — can this be solved with a library already in use?
- [ ] Bundle size impact — warn when adding a large library (based on bundlephobia)
- [ ] License compatibility — check for restrictive licenses such as GPL

### When Upgrading Versions
- [ ] Is it a major version change? → Need to check for breaking changes
- [ ] Has the changelog / migration guide been reviewed?
- [ ] Are there any peer dependency conflicts?

### Lock Files
- [ ] Is the lock file change intentional? (Suspicious if only the lock file changed without any dependency changes)
- [ ] Is the lock file included in the commit?

## Judgment Criteria

| Issue | Severity |
|-------|----------|
| Adding an unmaintained library | ❌ FAIL |
| Feature overlap with existing dependencies | ⚠️ WARNING |
| Major version upgrade (breaking change) | ⚠️ WARNING |
| Adding a large bundle (> 50KB gzipped) | ⚠️ WARNING |
| GPL license | ⚠️ WARNING |
| Unclear intent behind lock file changes | ⚠️ WARNING |
