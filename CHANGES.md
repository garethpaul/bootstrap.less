# Changes

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
