# Static Mailto Query Encoding

Status: Completed
Date: 2026-06-09

## Goal

Keep static link attributes valid by avoiding raw whitespace in `href` query
strings.

## Changes

- URL-encoded the footer mailto subject query string.
- Added a static baseline guard that rejects raw whitespace inside `href`
  attributes.
- Documented the link-encoding guard in the README, changelog, and vision.

## Verification

- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`
