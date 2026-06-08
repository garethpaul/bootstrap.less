---
title: Static LESS Demo Baseline
type: fix
status: completed
date: 2026-06-08
---

# Static LESS Demo Baseline

## Summary

Raise the baseline for the historical Bootstrap.less static demo by fixing
invalid HTML, removing insecure page URLs, documenting the no-build project
shape, and adding a lightweight source check.

## Problem Frame

The repository is a static browser demo with `index.html`, `style.less`,
`bootstrap.less`, and a checked-in `less-1.1.3.min.js` runtime compiler. There
is no package manager or build command. The page had a malformed `<title>` tag,
HTTP links/scripts, and no local verification guidance.

## Requirements

- R1. `index.html` must have valid title markup.
- R2. Demo-page links and external scripts must use HTTPS.
- R3. New-tab links must include `rel="noopener noreferrer"`.
- R4. The checked-in LESS runtime and source files must remain present.
- R5. The repository must document the static-server verification path.
- R6. The baseline check must run without Node, npm, or browser automation.

## Key Technical Decisions

- **Keep the browser LESS runtime:** This pass preserves the historical demo
  behavior instead of adding a modern build system.
- **Use source checks:** Simple shell checks can catch malformed title markup,
  insecure page URLs, missing local assets, and unsafe new-tab links.
- **Avoid broad content rewrites:** The original demo copy and mixin examples
  remain intact.

## Scope Boundaries

- This pass does not compile LESS to CSS.
- This pass does not upgrade LESS or rewrite the Bootstrap.less mixins.
- This pass does not redesign the demo page.

## Verification

- `scripts/check-baseline.sh`
- `git diff --check`

## Sources / Research

- `index.html` loads `style.less` and `less-1.1.3.min.js`.
- `style.less` imports `bootstrap.less`.
- `README.md` was empty before this baseline.
