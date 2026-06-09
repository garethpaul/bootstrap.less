# Static Button Sample Radius Parameter

Status: Completed
Date: 2026-06-09

## Goal

Keep the visible `.button()` demo snippet aligned with the checked-in LESS mixin
so readers do not copy an obsolete radius parameter or helper call.

## Changes

- Updated the HTML button snippet to use the checked-in `@borderRadius`
  parameter name.
- Updated the snippet to call `.border-radius(@borderRadius)` instead of the
  obsolete `.rounded(6px)` helper call.
- Extended the static baseline and documentation to enforce the snippet/source
  alignment.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
