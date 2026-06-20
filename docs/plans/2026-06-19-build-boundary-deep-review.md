# Build Boundary Deep Review

## Status: Completed

## Scope

Deep review of PRs #2 through #7 and the resulting archived static LESS build,
page, and GitHub Actions boundaries.

## Findings

- PR #5 introduced direct `lessc style.less style.css` output. A symlinked
  `style.css` therefore redirected `make build` outside the checkout and
  overwrote the target.
- The direct compiler commands followed symlinked inputs, accepted additional
  imports, and placed no explicit bound on source or generated output size.
- LESS `data-uri()` could read arbitrary local files into generated CSS, and
  `@plugin` could execute local plugin code during compilation.
- The README still described browser-side one-time compilation after PR #5 had
  replaced that runtime with committed precompiled CSS.
- The checkout action was correctly commit-pinned but one release behind the
  current official v7.0.0 release.

## Resolution

- Route lint, generated-output checks, and builds through a repository-derived
  Node wrapper using the locked local LESS 4.6.6 package.
- Reject symlinked or non-regular sources, output, dependency roots, and package
  roots; allow only the checked-in `bootstrap.less` import; reject executable
  plugins and file-reading LESS functions.
- Bound each LESS input to 1 MiB and generated CSS to 2 MiB.
- Compile fully before creating an exclusive temporary file, sync it, and
  atomically rename it over the regular repository output.
- Add executable tests for exact CSS fidelity, stale output, symlink escapes,
  failed compilation preservation, import escape, size bounds, compiler
  resolution, package routing, and workflow policy.
- Update checkout to commit-pinned v7.0.0 while retaining read-only permissions
  and disabled persisted credentials.

## Evidence

- Clean `npm ci --ignore-scripts --omit=optional` and `npm audit --omit=optional`
  completed with zero known vulnerabilities.
- Root and external-directory `make check` passed.
- Eighteen Node tests passed and thirteen isolated hostile mutations were
  killed.
- The current-tree and full 43-commit history credential scans found no leaks.
- GitHub code-scanning, secret-scanning, and Dependabot APIs reported zero open
  alerts before consolidation.

## Residual Risk

- The LESS source intentionally preserves 2012-era prefixes, layout techniques,
  and browser assumptions; visual fidelity in obsolete browsers is not proven.
- Browser interaction remains a bounded manual smoke test because the deployed
  page is static and script-free.
- The two 2026-06-13 plans remain historical records of an intermediate browser
  runtime and are not the current deployment contract.
