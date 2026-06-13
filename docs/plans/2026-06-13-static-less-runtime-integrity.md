---
title: Static LESS Runtime Integrity Pin
type: security
status: completed
date: 2026-06-13
---

# Static LESS Runtime Integrity Pin

## Status: Completed

## Problem Frame

The page executes the checked-in, minified LESS 1.1.3 browser runtime without an
HTML integrity binding. The repository preserves that legacy runtime by design,
but `index.html` does not tell the browser which exact bytes are expected and
the static gate does not detect drift between the reviewed runtime and its
script reference.

## Scope Boundaries

- Preserve `less-1.1.3.min.js` byte-for-byte, the production-mode configuration,
  `style.less`, `bootstrap.less`, and client-side initial compilation.
- Do not add a CDN, package manager, generated CSS artifact, dependency update,
  Content Security Policy, or other runtime behavior change.
- Keep the page usable from a local static server and retain all accessibility,
  privacy, layout, and sharing behavior.
- Treat the legacy runtime's dynamic evaluation as a separately documented
  modernization risk rather than claiming an incompatible strict CSP.

## Implementation Units

### U1: Bind The Script Tag To The Reviewed Runtime

Files:

- Modify `index.html`

Approach:

- Add the exact SHA-256 Subresource Integrity value for the checked-in runtime.
- Add anonymous CORS mode so the integrity contract remains explicit if the
  demo is later served through a different static origin arrangement.
- Keep script order and production configuration unchanged.

### U2: Enforce Runtime Bytes And Markup Together

Files:

- Modify `scripts/check-baseline.sh`

Approach:

- Require the reviewed runtime's exact SHA-256 file digest.
- Require exactly one matching script tag with the expected `src`, `integrity`,
  and `crossorigin` attributes.
- Reject unpinned or duplicate LESS runtime loads and preserve the existing
  one-time compilation ordering checks.

### U3: Document The Supply-Chain Boundary

Files:

- Modify `README.md`
- Modify `SECURITY.md`
- Modify `CHANGES.md`
- Modify `VISION.md`

Approach:

- Record what the integrity pin protects and what it does not modernize.
- Require completed plan and limited browser-verification evidence in the
  static gate.

## Verification

- `make check` and `make verify` passed the static source baseline and all root
  wrappers.
- Absolute-path `make check` passed from `/tmp`.
- `sh -n scripts/check-baseline.sh`, `git diff --check`, and Python's
  standard-library HTML parser passed.
- A bounded local HTTP server and bounded headless Chrome confirmed that the
  integrity-pinned runtime injected the compiled `style.less` output without an
  integrity error.
- Nine isolated hostile mutations were rejected across runtime bytes, integrity
  value, missing integrity, CORS mode, duplicate load, runtime source, README,
  security guidance, and headless Chrome evidence.
- The historical runtime still uses dynamic evaluation; no strict Content
  Security Policy or dependency-modernization claim is made.
