# Changes

## 2026-06-14

- Replaced browser-side LESS 1.1.3 execution with committed generated CSS and a
  restrictive script-free Content Security Policy.
- Added a pinned LESS 4.6.6 build with a frozen lockfile, warning-free source
  syntax, generated-output drift checks, and a script-disabled CI install that
  omits unused optional compiler features.
- Contained long code-sample overflow so the generated page remains within a
  375px mobile viewport.

## 2026-06-13

- Bound the checked-in LESS 1.1.3 runtime to its reviewed SHA-256 digest through
  Subresource Integrity and an exact static source contract.
- Configured the bundled LESS runtime for production before load and removed
  the permanent development watch loop.
- Preserved client-side initial stylesheet compilation without adding generated
  CSS or a package-manager build.

## 2026-06-12

- Documented GitHub CodeQL default setup for Actions, rejected a conflicting
  advanced workflow, and recorded the browser JavaScript analysis gap.
- Added a keyboard skip link and a single focusable main landmark around the
  long Bootstrap.less reference content.
- Added explicit high-contrast link focus styling and an SDK-free regression
  guard for skip-link target integrity and landmark source order.

## 2026-06-10

- Replaced the page-load Twitter widgets runtime with two encoded, descriptive
  Web Intent links so sharing remains user-triggered without an automatic
  third-party script request.
- Bounded the historical fixed-width layout and stacked its overview columns on
  narrow screens after browser verification exposed mobile clipping.
- Made root Makefile checks location-independent and pinned CI to the stable
  Ubuntu 24.04 runner image.
- Added a GitHub Actions check workflow that runs the existing static
  `make check` baseline on pushes, pull requests, and manual dispatches.
- Pinned the checkout action and limited the workflow token to read-only
  repository access with bounded execution.
- Added a static guard requiring the CI workflow and completed CI baseline plan
  to remain checked in without adding a package manager.

## 2026-06-09

- Added a mobile viewport meta tag to keep the static demo sized to the device
  width when opened directly.
- Added a document-wide `no-referrer` policy so every static page request and
  outbound handoff follows the privacy baseline.
- Aligned the visible button snippet with the checked-in `.button()` border
  radius parameter and helper call.
- URL-encoded the footer mailto query string and added a static baseline guard
  against raw whitespace inside `href` attributes.
- Added root `make lint`, `make test`, `make build`, and `make check` gates
  around the static source baseline without adding a package manager.
- Added a `no-referrer` policy to the Twitter share links so clicked share
  actions match the existing widgets script referrer baseline.
- Added a `no-referrer` policy to the single async Twitter widgets script load
  and guarded it in the static baseline.
- Fixed the `.opacity(@opacity)` mixin to use its declared `@opacity` parameter
  instead of the undefined `@op` variable.
- Extended the static baseline and README notes to guard the opacity mixin
  contract without adding a build pipeline.

## 2026-06-08

- Loaded the Twitter widgets script once with `async` instead of duplicating it
  beside each share button.
- Added `make check` as the SDK-free static baseline wrapper.
- Restored README verification notes for the static no-build baseline after the
  generated project overview refresh.
- Fixed malformed HTML title markup in the demo page.
- Replaced insecure HTTP links and third-party script URLs in `index.html` with
  HTTPS equivalents.
- Added `rel="noopener noreferrer"` to links that open a new tab.
- Added a static baseline check and documented the no-package verification path.
