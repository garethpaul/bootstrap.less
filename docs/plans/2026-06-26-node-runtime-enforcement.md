# Node Runtime Enforcement

Status: Completed

## Goal

Prevent unsupported Node runtimes from reporting a successful LESS compiler
gate after npm emits only an engine warning.

## Work

- Added `assertSupportedNodeVersion` and a `20.19.0` minimum constant.
- Invoked the guard before argument handling and LESS package loading.
- Covered older majors, Node 20.18, malformed and prerelease versions, the
  exact floor, and newer stable majors.
- Updated repository guidance and the June 26 audit record.
- Added static integration contracts so removing the CLI call is rejected.

## Verification

- Red-first focused test failed because `assertSupportedNodeVersion` did not
  exist.
- Focused runtime-boundary tests passed after implementation.
- The compiler CLI rejected the host's unsupported Node 18.19 runtime.
- A temporary Node 20.19 runtime passed root and external-directory
  `make check`, all 19 Node tests, generated CSS fidelity, and the build.
- `npm audit --omit=optional` reported zero vulnerabilities.
- GitHub Dependabot, code-scanning, and secret-scanning queues reported zero
  open alerts before the change.
- Shell syntax, whitespace, generated-artifact, and likely-secret audits
  passed.
- Hosted Check and CodeQL results are recorded on the pull request before
  merge.

## Runtime Boundary

No browser visual or interaction smoke test was executed locally. The deployed
page remains static and script-free; this change affects build validation only.
