# Static Opacity Mixin Variable

## Status: Completed

## Goal

Fix the historical `.opacity(@opacity)` mixin so it uses its declared
`@opacity` parameter instead of the undefined `@op` variable.

## Scope

- Preserve the `.opacity(@opacity: 100)` mixin signature.
- Replace internal `@op` references with `@opacity`.
- Extend the source baseline to guard against the undefined variable returning.
- Document the mixin fix in the README and changelog.

## Out Of Scope

- Rewriting the legacy gradient, flexbox, or browser-prefix mixins.
- Adding a Node, npm, or Less build pipeline.
- Compiling checked-in CSS artifacts.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `git diff --check`
