# Static Make Gate Targets

Status: Completed
Date: 2026-06-09

## Goal

Expose standard root verification targets for the static LESS demo without
adding a package manager, generated CSS artifact, or build pipeline.

## Changes

- Added root `make lint`, `make test`, `make build`, `make verify`, and
  `make check` targets.
- Kept each target tied to the SDK-free static baseline so HTML, LESS, local
  Less.js, link-safety, and Twitter referrer-policy checks remain repeatable.
- Made `make build` report that `index.html` is the runnable artifact instead
  of implying a generated bundle exists.
- Extended README, changelog, vision, and source-baseline checks for the new
  gate contract.

## Verification

- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`
