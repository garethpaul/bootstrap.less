# Static Viewport Meta Baseline

Status: Completed

## Context

The demo is intended to be opened directly as a static page, but the document
had no viewport meta tag. Mobile browsers can then apply a desktop layout width
before scaling, which makes local viewing less predictable.

## Plan

- Add a standard viewport meta tag next to the existing charset and referrer
  metadata.
- Extend the static baseline so the viewport tag remains present.
- Document the mobile local-viewing baseline in the README, changelog, and
  vision notes.

## Verification

- `scripts/check-baseline.sh`
- `git diff --check`
- `make check`
