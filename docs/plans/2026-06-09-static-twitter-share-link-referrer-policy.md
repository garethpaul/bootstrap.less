# Static Twitter Share Link Referrer Policy

Status: Completed
Date: 2026-06-09

## Goal

Keep the demo page from sending its referrer when users click the Twitter share
links.

## Changes

- Added `referrerpolicy="no-referrer"` to both Twitter share anchors.
- Extended the static baseline to require no-referrer share links and the
  completed plan.
- Documented the share-link privacy baseline in the README, changelog, and
  vision.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
