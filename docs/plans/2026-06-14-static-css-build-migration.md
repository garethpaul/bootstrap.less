---
title: Static CSS Build Migration
type: security
status: completed
date: 2026-06-14
---

# Static CSS Build Migration

## Status: Completed

## Problem Frame

The page still executes the historical LESS 1.1.3 compiler in every visitor's
browser. The integrity pin protects the reviewed file from unnoticed drift, but
it does not remove the legacy dynamic-evaluation runtime or provide a supported,
reproducible build for the checked-in LESS sources. An isolated feasibility
check confirmed that the sources compile with the current maintained `less`
4.6.6 CLI and identified deprecated parenthesis-free mixin calls that should be
modernized before they become build errors.

## Prioritized Engineering Tasks

1. Replace browser-side compilation with a checked-in generated stylesheet so
   visitors execute no project JavaScript.
2. Pin `less` 4.6.6 and its resolved dependency graph for reproducible local and
   hosted builds.
3. Update deprecated mixin invocation syntax without changing generated CSS
   behavior.
4. Enforce script absence and a script-free Content Security Policy through the
   dependency-free baseline, and generated-output freshness through the pinned
   compiler gate.
5. Validate the built page in a real browser and retain accessibility,
   responsive layout, privacy, and user-triggered sharing behavior.

## Scope Boundaries

- Preserve `style.less` and `bootstrap.less` as the maintained source of truth.
- Preserve page content, layout, skip navigation, visible focus, responsive
  behavior, no-referrer policy, safe external links, and user-triggered sharing.
- Do not introduce a framework, bundler, development server, CDN dependency, or
  automatic third-party request.
- Do not retain or replace the browser LESS compiler with another runtime
  script.
- Keep the generated CSS reviewable and committed so the static page remains
  directly deployable.
- Do not merge or close any pull request without explicit owner authorization.

## Implementation Units

### U1: Add A Reproducible CSS Build

Files:

- Add `package.json`
- Add `package-lock.json`
- Add generated `style.css`
- Modify `Makefile`
- Modify `.gitignore`

Approach:

- Pin `less` 4.6.6 exactly and require a supported Node runtime.
- Define a deterministic build command from `style.less` to `style.css`.
- Make the root build and check gates compile CSS and reject generated-output
  drift while keeping dependency installation outside the Make targets.
- Exclude dependency directories and temporary build artifacts from git.

### U2: Modernize LESS Source Syntax

Files:

- Modify `style.less`
- Modify `bootstrap.less`

Approach:

- Add explicit parentheses to namespace mixin calls reported as deprecated by
  LESS 4.6.6.
- Require a warning-free compile and preserve the generated selectors and
  declarations expected by the existing page contracts.

### U3: Remove Browser Runtime Execution

Files:

- Modify `index.html`
- Remove `less-1.1.3.min.js`

Approach:

- Load the generated `style.css` as a normal stylesheet.
- Remove the global LESS configuration and compiler script.
- Add a restrictive script-free meta Content Security Policy compatible with
  the static page's local styles, links, and images.

### U4: Extend Static, CI, And Documentation Contracts

Files:

- Modify `scripts/check-baseline.sh`
- Modify `.github/workflows/check.yml`
- Modify `AGENTS.md`
- Modify `README.md`
- Modify `SECURITY.md`
- Modify `VISION.md`
- Modify `CHANGES.md`
- Complete this plan after measured verification

Approach:

- Reject browser scripts, LESS runtime references, stale generated CSS,
  dependency drift, deprecated mixin calls, and weakened CSP.
- Install the frozen dependency graph in CI before the full Make gate.
- Document the build source of truth, deployment artifact, and removed runtime
  trust boundary.

## Work Completed

- Replaced the browser LESS 1.1.3 runtime with committed generated `style.css`
  and removed all project script markup.
- Pinned LESS 4.6.6 and its exact dependency graph, modernized deprecated mixin
  calls, and added warning-free build and generated-output gates.
- Added a script-free Content Security Policy and updated CI to use pinned Node
  setup plus a frozen install with lifecycle scripts disabled.
- Contained long code samples so a 375px viewport no longer develops horizontal
  document overflow.

## Verification Results

- `npm ci --ignore-scripts --omit=optional` installed five audited packages from
  the exact lockfile; `npm audit --audit-level=moderate --omit=optional`
  reported zero vulnerabilities and `npm outdated` reported no updates.
- `make check` and `make verify` passed the dependency-free baseline, warning-free
  LESS lint, generated-output comparison, and reproducible CSS build.
- Standard-library HTML, JSON, and workflow YAML parsing passed, as did shell
  syntax, whitespace, conflict-marker, and changed-line credential audits.
- A bounded local server and headless Chrome 80 desktop/mobile smoke confirmed
  one generated stylesheet, zero scripts, no CSP/console/page errors, no
  automatic third-party requests, working skip-link focus, and exact 375px
  document width with code overflow contained locally. A separate direct
  `file://` load also applied the generated stylesheet without console errors.
- The gates rejected 15 hostile mutations covering dependency pins, build and
  generated-output commands, CI install/action pinning, script/runtime markup,
  CSP, deprecated mixin calls, mobile overflow, stale CSS, documentation, and
  completed plan evidence.

## Residual Risks

- The source remains a historical Bootstrap.less reference and is not a modern
  Bootstrap implementation.
- Generated CSS must be refreshed whenever either LESS source file changes.
- Browser coverage remains bounded to the locally available headless Chrome
  runtime unless hosted cross-browser testing is added separately.
