# Static README Baseline

## Goal

Keep the generated README aligned with the static Bootstrap.less demo baseline.

## Scope

- Document the SDK-free source baseline command.
- Document the root `make check` wrapper.
- Preserve the no-package-manager and no-build project shape.
- Document that `index.html` is the local demo entry point.
- Avoid changing demo HTML, LESS, or the checked-in LESS runtime.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
