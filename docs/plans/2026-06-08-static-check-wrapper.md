---
title: Static Check Wrapper
type: chore
status: completed
date: 2026-06-08
---

# Static Check Wrapper

## Summary

Expose the existing source-only Bootstrap.less baseline through the conventional
root `make check` command.

## Requirements

- R1. Preserve the no-package-manager and no-build project shape.
- R2. Keep `scripts/check-baseline.sh` as the underlying verification gate.
- R3. Document `make check` in the README.
- R4. Make the baseline script guard the wrapper.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `git diff --check`
