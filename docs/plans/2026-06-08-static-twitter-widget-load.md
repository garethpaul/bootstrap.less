---
title: Static Twitter Widget Load
type: fix
status: completed
date: 2026-06-08
---

# Static Twitter Widget Load

## Summary

Keep both Tweet share buttons while loading the third-party Twitter widgets
script once, asynchronously, after the page content.

## Requirements

- R1. The demo continues to use the checked-in LESS runtime and browser compile path.
- R2. Tweet share links remain present in the header and footer.
- R3. `platform.twitter.com/widgets.js` is loaded exactly once.
- R4. The Twitter widgets script uses `async` so page rendering is not blocked.
- R5. README and changelog notes document the source-level baseline.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `git diff --check`
