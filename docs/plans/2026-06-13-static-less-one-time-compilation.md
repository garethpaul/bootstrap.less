---
title: Static LESS One-Time Compilation
type: performance
status: completed
date: 2026-06-13
---

# Static LESS One-Time Compilation

## Status: Completed

## Problem Frame

The static page loads the checked-in LESS 1.1.3 runtime, then switches it to
development mode and calls `less.watch()`. The bundled runtime already performs
an initial stylesheet refresh, while watch mode keeps a polling timer active for
the lifetime of the page. Ordinary readers therefore pay continuous polling and
recompilation overhead intended only for authoring.

## Scope Boundaries

- Preserve the checked-in LESS 1.1.3 runtime, `style.less`, `bootstrap.less`, and
  client-side initial compilation.
- Do not add a package manager, generated CSS artifact, CDN dependency, or
  modern LESS migration.
- Preserve all page content, accessibility, privacy, responsive layout, and
  user-triggered sharing behavior.
- Do not claim cross-browser coverage while `agent-browser` is unavailable.

## Implementation Units

### U1: Configure Production Mode Before Runtime Load

Files:

- Modify `index.html`

Approach:

- Define the global LESS configuration with `env: "production"` before loading
  `less-1.1.3.min.js`.
- Keep the runtime script after the stylesheet link so its initial refresh still
  discovers and compiles `style.less`.
- Remove the post-load development assignment and `less.watch()` call.

### U2: Extend Static And Documentation Contracts

Files:

- Modify `scripts/check-baseline.sh`
- Modify `README.md`
- Modify `CHANGES.md`
- Modify `VISION.md`

Approach:

- Require one production configuration before one runtime script.
- Reject development mode, `less.watch()`, watch URL flags, and additional LESS
  runtime loads.
- Require documentation and completed plan evidence.
- Preserve the existing rendered-browser limitation truthfully.

## Verification

- `make check` and `make verify` passed the static source baseline and all root
  wrappers.
- Absolute-path `make check` passed from `/tmp`.
- `sh -n scripts/check-baseline.sh` and `git diff --check` passed.
- Python's standard-library HTML parser accepted `index.html`.
- A race-free one-shot local TCP server returned `index.html` byte-for-byte with
  an HTTP 200 response.
- Eight isolated hostile mutations were rejected across production mode,
  missing/reordered configuration, watch restoration, runtime duplication,
  initial refresh drift, and README evidence.
- `agent-browser` is not installed, so no rendered interaction or screenshot
  claim is made for this pass.
