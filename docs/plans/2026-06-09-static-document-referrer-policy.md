# Static Document Referrer Policy

Status: Completed
Date: 2026-06-09

## Goal

Keep the static demo from sending the page URL as a referrer during subresource
loads or outbound navigation.

## Changes

- Added a document-wide `<meta name="referrer" content="no-referrer">` policy
  in `index.html`.
- Extended the static baseline to require the page-level referrer policy and
  the completed plan.
- Documented the page-level privacy baseline in the README, changelog, and
  vision.

## Verification

- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`
