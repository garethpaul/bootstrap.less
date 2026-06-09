# Changes

## 2026-06-09

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
