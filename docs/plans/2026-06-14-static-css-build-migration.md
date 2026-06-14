---
title: Static CSS Build Migration
type: security
status: planned
date: 2026-06-14
---

# Static CSS Build Migration

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
4. Enforce generated-output freshness, script absence, and a script-free
   Content Security Policy through the dependency-free baseline.
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

## Verification

- Install exactly from `package-lock.json` with lifecycle scripts disabled.
- Run focused source and generated-output checks, then the full `make check`
  and `make verify` gates.
- Parse HTML, JSON, and workflow YAML with structured parsers.
- Serve the static directory through a bounded local server and verify in
  headless Chrome that CSS loads, no script executes, no CSP violation occurs,
  skip navigation works, and no third-party request is automatic.
- Reject hostile mutations covering dependency pins, build command, generated
  drift, deprecated mixin syntax, stylesheet/runtime markup, CSP, CI install,
  documentation, and completed plan evidence.
- Audit exact diff, generated artifacts, whitespace, conflict markers, and
  credential-shaped additions before committing implementation files.

## Residual Risks

- The source remains a historical Bootstrap.less reference and is not a modern
  Bootstrap implementation.
- Generated CSS must be refreshed whenever either LESS source file changes.
- Browser coverage remains bounded to the locally available headless Chrome
  runtime unless hosted cross-browser testing is added separately.
