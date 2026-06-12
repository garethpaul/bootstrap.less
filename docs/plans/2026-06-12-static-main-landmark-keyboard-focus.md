# Static Main Landmark And Keyboard Focus

## Status: Completed

## Goal

Let keyboard and assistive-technology users reach the Bootstrap.less reference
content directly while preserving the historical demo's visual design.

## Problem

The page is a long technical reference, but its content sections are not
grouped in a `main` landmark and there is no skip link before the header.
Keyboard users must traverse the header controls before reaching the mixin
documentation, and focused links have no explicit treatment beyond browser
defaults.

## Scope

- Add one skip link as the first interactive element in the document body.
- Wrap the existing reference sections in one focusable `main` landmark.
- Add visible link focus styling and reveal the skip link only when focused.
- Extend the package-manager-free baseline and maintenance documentation for
  the accessibility contract.

## Out Of Scope

- Reordering or rewriting the historical documentation content.
- Redesigning the page, grid, typography, buttons, or responsive layout.
- Replacing the checked-in Less.js runtime or adding a browser dependency.

## Verification

- `make check`
- `sh -n scripts/check-baseline.sh`
- Targeted baseline mutation checks
- `git diff --check`
- One desktop and one mobile screenshot review with local Google Chrome
