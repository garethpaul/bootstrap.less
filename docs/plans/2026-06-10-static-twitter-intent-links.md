# Static Twitter Web Intent Links

## Status: Completed

## Context

The static demo loaded `platform.twitter.com/widgets.js` on every page view only
to transform two share anchors. That automatic third-party request was not
required for sharing: X's documented Web Intent endpoint supports ordinary
links with encoded `url` and `via` parameters. The widget also made the page's
share controls depend on remote JavaScript despite the repository's no-build,
locally runnable shape.

## Objectives

- Preserve both share affordances in their existing header and footer locations.
- Make sharing an explicit user action through ordinary anchor navigation.
- Remove the automatic Twitter widgets script request and widget-only markup.
- Encode share query parameters and retain no-referrer and opener isolation.
- Reuse the existing demo button treatment without adding CSS or JavaScript.
- Keep the replacement controls and historical grid visible on narrow screens.
- Keep the new contract verifiable with the SDK-free source baseline.

## Work Completed

- Replaced both widget anchors with descriptive Twitter Web Intent links.
- Encoded the historical article URL and attribution account in each link.
- Added isolated new-tab behavior and retained the no-referrer policy.
- Removed the external Twitter widgets script and transformation-only classes
  and data attributes.
- Extended the baseline to require exactly two safe intent links and reject the
  removed third-party runtime and widget markup.
- Added a legacy-compatible narrow-screen layout after screenshot verification
  exposed clipping from the historical fixed 640px page and grid widths.
- Made Makefile checks repository-rooted and fixed CI to Ubuntu 24.04.
- Updated README, VISION, and CHANGES with the user-triggered sharing contract.

## Verification

- `make check`
- `make -f /tmp/bootstrap-less-second-pass/Makefile check`
- `scripts/check-baseline.sh`
- Baseline mutation checks for intent count, encoding, link safety, script
  removal, widget markup removal, plan status, Makefile, and CI contracts
- `sh -n scripts/check-baseline.sh`
- `git diff --check`
- One browser screenshot review of the local static page

The checked-in Less.js runtime remains intentionally preserved. No package
manager, generated CSS artifact, or additional browser dependency was added.

## Follow-Up Candidates

- Document browser compatibility expectations for Less.js 1.1.3.
- Replace the historical share destination only if project attribution or the
  canonical source material changes.
