# Bootstrap.less CI Baseline

## Status: Completed

## Context

`bootstrap.less` is a static no-build LESS demo with source checks behind
`make check`. The repository needs the same package-manager-free baseline to run
in GitHub Actions before review.

## Objectives

- Run the existing static baseline in GitHub Actions.
- Avoid adding a package manager or build pipeline to the preserved demo.
- Minimize workflow token access and pin third-party action code by commit.
- Make the workflow presence part of the static source baseline contract.

## Work Completed

- Added `.github/workflows/check.yml` to run `make check` on pushes, pull
  requests, and manual dispatches.
- Pinned `actions/checkout` to a reviewed commit, limited repository access to
  read-only, and bounded runs with a timeout and concurrency cancellation.
- Reused the existing Makefile targets without introducing Node, npm, or a
  generated CSS artifact.
- Extended `scripts/check-baseline.sh` to require the CI workflow and this
  completed plan.
- Updated README, VISION, SECURITY, and CHANGES with the CI baseline.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `git diff --check`

## Follow-Up Candidates

- Add browser smoke coverage only if the static demo gains an owned test
  harness.
