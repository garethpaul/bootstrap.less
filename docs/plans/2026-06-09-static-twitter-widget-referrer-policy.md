# Static Twitter Widget Referrer Policy

## Status: Completed

## Goal

Keep the demo page's only external script request from sending the local page
URL as a referrer while preserving the existing Twitter share button behavior.

## Scope

- Preserve the static no-build demo shape.
- Keep loading `https://platform.twitter.com/widgets.js` exactly once.
- Keep the script asynchronous.
- Add a source-level guard for the script referrer policy.

## Out Of Scope

- Removing the historical Twitter share buttons.
- Adding a package manager, bundler, or generated CSS output.
- Replacing the checked-in Less.js runtime.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `git diff --check`
