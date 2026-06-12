#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
INDEX="$ROOT_DIR/index.html"
MAKE_GATE_PLAN="docs/plans/2026-06-09-static-make-gate-targets.md"
MAILTO_ENCODING_PLAN="docs/plans/2026-06-09-static-mailto-query-encoding.md"
BUTTON_SAMPLE_PLAN="docs/plans/2026-06-09-static-button-sample-radius-parameter.md"
DOCUMENT_REFERRER_PLAN="docs/plans/2026-06-09-static-document-referrer-policy.md"
VIEWPORT_PLAN="docs/plans/2026-06-09-static-viewport-meta-baseline.md"
CI_PLAN="docs/plans/2026-06-10-ci-baseline.md"
TWITTER_INTENT_PLAN="docs/plans/2026-06-10-static-twitter-intent-links.md"
KEYBOARD_FOCUS_PLAN="docs/plans/2026-06-12-static-main-landmark-keyboard-focus.md"

require_file() {
  path=$1
  if [ ! -f "$ROOT_DIR/$path" ]; then
    printf '%s\n' "Required file is missing: $path" >&2
    exit 1
  fi
}

require_contains() {
  path=$1
  pattern=$2
  message=$3

  if ! grep -Fq "$pattern" "$ROOT_DIR/$path"; then
    printf '%s\n' "$message" >&2
    exit 1
  fi
}

for path in \
  "README.md" \
  "CHANGES.md" \
  "docs/plans/2026-06-08-static-less-demo-baseline.md" \
  "docs/plans/2026-06-09-static-opacity-mixin-variable.md" \
  "docs/plans/2026-06-09-static-twitter-share-link-referrer-policy.md" \
  "$MAKE_GATE_PLAN" \
  "$MAILTO_ENCODING_PLAN" \
  "$BUTTON_SAMPLE_PLAN" \
  "$DOCUMENT_REFERRER_PLAN" \
  "$VIEWPORT_PLAN" \
  "$CI_PLAN" \
  "$TWITTER_INTENT_PLAN" \
  "$KEYBOARD_FOCUS_PLAN" \
  ".github/workflows/check.yml" \
  "index.html" \
  "style.less" \
  "bootstrap.less" \
  "less-1.1.3.min.js"; do
  require_file "$path"
done

require_contains "index.html" "<title>Bootstrap.less</title>" \
  "index.html must contain a valid title tag."
require_contains "index.html" '<meta name="viewport" content="width=device-width, initial-scale=1">' \
  "index.html must include a mobile viewport baseline."
require_contains "index.html" 'href="style.less"' \
  "index.html must load the demo LESS file."
require_contains "index.html" 'src="less-1.1.3.min.js"' \
  "index.html must load the checked-in LESS runtime."
require_contains "index.html" '<meta name="referrer" content="no-referrer">' \
  "index.html must set a document-wide no-referrer policy."
require_contains "index.html" '<a class="skip-link" href="#main-content">Skip to main content</a>' \
  "index.html must offer a skip link to the main reference content."
require_contains "index.html" '<main id="main-content" tabindex="-1">' \
  "index.html must expose a focusable main landmark for the skip link."
require_contains "style.less" "&:focus {" \
  "Static page links must preserve an explicit keyboard focus state."
require_contains "style.less" "a.skip-link:focus" \
  "The skip link must become visible when focused."
require_contains "style.less" "main { display: block; }" \
  "The main landmark must remain block-level in older browsers."
require_contains "style.less" "top: -100px;" \
  "The skip link must remain outside the normal visual flow until focused."
require_contains "style.less" "outline: 3px solid rgba(255,255,255,.9);" \
  "Static page links must retain a high-contrast focus outline."
require_contains "index.html" "less.watch();" \
  "index.html must preserve the browser LESS watch behavior."

if [ "$(grep -Foc '<a class="skip-link" href="#main-content">' "$INDEX")" -ne 1 ] || \
   [ "$(grep -Foc '<main id="main-content" tabindex="-1">' "$INDEX")" -ne 1 ] || \
   [ "$(grep -Foc '</main>' "$INDEX")" -ne 1 ]; then
  printf '%s\n' "index.html must contain exactly one skip link and main landmark." >&2
  exit 1
fi

skip_line=$(grep -Fn '<a class="skip-link" href="#main-content">' "$INDEX" | cut -d: -f1)
header_line=$(grep -Fn '<header>' "$INDEX" | cut -d: -f1)
main_line=$(grep -Fn '<main id="main-content" tabindex="-1">' "$INDEX" | cut -d: -f1)
first_section_line=$(grep -Fn '<section>' "$INDEX" | head -n 1 | cut -d: -f1)
main_end_line=$(grep -Fn '</main>' "$INDEX" | cut -d: -f1)
footer_line=$(grep -Fn '<footer>' "$INDEX" | cut -d: -f1)

if [ "$skip_line" -ge "$header_line" ] || [ "$main_line" -ge "$first_section_line" ] || \
   [ "$main_end_line" -ge "$footer_line" ]; then
  printf '%s\n' "Skip, main, section, and footer landmarks must remain in accessible source order." >&2
  exit 1
fi
require_contains "index.html" 'href="mailto:hi@markdotto.com?subject=About%20Bootstrap"' \
  "Mailto query strings must be URL-encoded."
require_contains "style.less" '@import "bootstrap.less";' \
  "style.less must import bootstrap.less."
require_contains "style.less" "max-width: 640px;" \
  "Static page sections must remain bounded without forcing mobile overflow."
require_contains "style.less" "@media (max-width: 700px)" \
  "Static page must preserve its narrow-screen layout overrides."
require_contains "style.less" "div.span5" \
  "Static page must stack the two-column overview on narrow screens."
require_contains "style.less" "float: none;" \
  "Static page must release fixed floats on narrow screens."

if [ "$(grep -Foc "float: none;" "$ROOT_DIR/style.less")" -ne 2 ]; then
  printf '%s\n' "Static page must release both the share control and overview columns on narrow screens." >&2
  exit 1
fi
require_contains "bootstrap.less" ".opacity(@opacity: 100)" \
  "bootstrap.less must preserve the opacity mixin signature."
require_contains "bootstrap.less" "opacity: @opacity / 100;" \
  "Opacity mixin must use its declared parameter for standard opacity."
require_contains "index.html" "@borderRadius: 6px" \
  "Button demo snippet must document the checked-in border radius parameter."
require_contains "index.html" ".border-radius(@borderRadius);" \
  "Button demo snippet must pass its border radius parameter to the helper."
require_contains "less-1.1.3.min.js" "LESS - Leaner CSS v1.1.3" \
  "LESS runtime provenance header is missing."
require_contains "README.md" "scripts/check-baseline.sh" \
  "README must document the baseline check."
require_contains "README.md" "make check" \
  "README must document the make check wrapper."
require_contains "README.md" "make lint" \
  "README must document the lint gate."
require_contains "README.md" "make test" \
  "README must document the test gate."
require_contains "README.md" "make build" \
  "README must document the build gate."
require_contains "README.md" "GitHub Actions" \
  "README must document the GitHub Actions baseline."
require_contains "README.md" "no package manager and no build pipeline" \
  "README must document the no-build project shape."
require_contains "README.md" "less-1.1.3.min.js" \
  "README must document the checked-in LESS runtime."
require_contains "README.md" "CHANGES.md" \
  "README must point to CHANGES.md."
require_contains "README.md" "no automatic third-party script requests" \
  "README must document the third-party script removal."
require_contains "README.md" "self-contained Web Intent links" \
  "README must document the user-triggered Twitter sharing baseline."
require_contains "README.md" "stacks the overview grid on" \
  "README must document the responsive static-page guard."
require_contains "README.md" "Twitter share links also use a no-referrer policy" \
  "README must document the Twitter share link referrer policy."
require_contains "README.md" "document-wide no-referrer policy" \
  "README must document the document-wide referrer policy."
require_contains "README.md" "mobile viewport meta tag" \
  "README must document the viewport meta baseline."
require_contains "README.md" "opacity mixin uses its declared parameter" \
  "README must document the opacity mixin fix."
require_contains "README.md" "button snippet uses its declared border radius parameter" \
  "README must document the button demo snippet guard."
require_contains "README.md" "keyboard-accessible skip link" \
  "README must document keyboard skip navigation."
require_contains "README.md" "visible focus outline" \
  "README must document the visible keyboard focus baseline."
require_file "Makefile"
require_contains "Makefile" 'ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))' \
  "Makefile must resolve repository-root commands from its own location."
require_contains "Makefile" '$(ROOT)scripts/check-baseline.sh' \
  "Makefile must run the static baseline check."
require_contains "Makefile" "lint:" \
  "Makefile must expose a lint gate."
require_contains "Makefile" "test:" \
  "Makefile must expose a test gate."
require_contains "Makefile" "build:" \
  "Makefile must expose a build gate."
require_contains "Makefile" "verify: lint test build" \
  "Makefile must expose a combined verify gate."
require_contains ".github/workflows/check.yml" "uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10" \
  "GitHub Actions check workflow must pin the reviewed checkout commit."
require_contains ".github/workflows/check.yml" "permissions:" \
  "GitHub Actions check workflow must declare token permissions."
require_contains ".github/workflows/check.yml" "contents: read" \
  "GitHub Actions check workflow must keep repository access read-only."
require_contains ".github/workflows/check.yml" "workflow_dispatch:" \
  "GitHub Actions check workflow must support manual verification."
require_contains ".github/workflows/check.yml" "timeout-minutes: 5" \
  "GitHub Actions check workflow must bound baseline execution."
require_contains ".github/workflows/check.yml" "runs-on: ubuntu-24.04" \
  "GitHub Actions check workflow must use a stable hosted runner image."
require_contains ".github/workflows/check.yml" "cancel-in-progress: true" \
  "GitHub Actions check workflow must cancel superseded runs."
require_contains ".github/workflows/check.yml" "run: make check" \
  "GitHub Actions check workflow must run the static make check baseline."

if grep -Fq "http://" "$INDEX"; then
  printf '%s\n' "index.html must not contain insecure HTTP URLs." >&2
  exit 1
fi

if grep -Eq 'href="[^"]*[[:space:]][^"]*"' "$INDEX"; then
  printf '%s\n' "href attributes must not contain raw whitespace; URL-encode query strings." >&2
  exit 1
fi

if grep -Eq '@op([^[:alnum:]_-]|$)' "$ROOT_DIR/bootstrap.less"; then
  printf '%s\n' "bootstrap.less must not reference the undefined @op variable." >&2
  exit 1
fi

if grep -Fq ".rounded(6px);" "$INDEX" || grep -Fq "@rounded: 6px" "$INDEX"; then
  printf '%s\n' "Button demo snippet must not document the obsolete rounded parameter or helper." >&2
  exit 1
fi

if grep -F 'target="_blank"' "$INDEX" | grep -Fvq 'rel="noopener noreferrer"'; then
  printf '%s\n' "New-tab links must include rel=\"noopener noreferrer\"." >&2
  exit 1
fi

if grep -Fq 'platform.twitter.com/widgets.js' "$INDEX"; then
  printf '%s\n' "index.html must not contact the Twitter widgets runtime on page load." >&2
  exit 1
fi

if grep -Fq 'twitter-share-button' "$INDEX" || grep -Fq 'data-url=' "$INDEX" || grep -Fq 'data-via=' "$INDEX"; then
  printf '%s\n' "Twitter share links must not depend on widget-only markup." >&2
  exit 1
fi

TWITTER_INTENT='href="https://twitter.com/intent/tweet?url=https%3A%2F%2Fwww.markdotto.com%2F2011%2F03%2F21%2Fintroducing-bootstrap%2F&amp;via=mdo"'
TWITTER_INTENT_COUNT=$(grep -Foc "$TWITTER_INTENT" "$INDEX")
if [ "$TWITTER_INTENT_COUNT" -ne 2 ]; then
  printf '%s\n' "index.html must expose exactly two encoded Twitter Web Intent links." >&2
  exit 1
fi

if grep -F "$TWITTER_INTENT" "$INDEX" | grep -Fvq 'target="_blank" rel="noopener noreferrer" referrerpolicy="no-referrer"'; then
  printf '%s\n' "Twitter Web Intent links must isolate new tabs and suppress referrers." >&2
  exit 1
fi

if [ "$(grep -Foc '>Share on Twitter</a>' "$INDEX")" -ne 2 ]; then
  printf '%s\n' "Twitter Web Intent links must expose descriptive link text." >&2
  exit 1
fi
require_contains "docs/plans/2026-06-09-static-opacity-mixin-variable.md" "Status: Completed" \
  "Opacity mixin plan must record completed status."
require_contains "docs/plans/2026-06-09-static-opacity-mixin-variable.md" "make check" \
  "Opacity mixin plan must record make check verification."
require_contains "docs/plans/2026-06-09-static-twitter-widget-referrer-policy.md" "Status: Completed" \
  "Twitter widget referrer policy plan must record completed status."
require_contains "docs/plans/2026-06-09-static-twitter-widget-referrer-policy.md" "make check" \
  "Twitter widget referrer policy plan must record make check verification."
require_contains "docs/plans/2026-06-09-static-twitter-share-link-referrer-policy.md" "Status: Completed" \
  "Twitter share link referrer policy plan must record completed status."
require_contains "docs/plans/2026-06-09-static-twitter-share-link-referrer-policy.md" "make check" \
  "Twitter share link referrer policy plan must record make check verification."
require_contains "$MAKE_GATE_PLAN" "Status: Completed" \
  "Static make gate plan must record completed status."
require_contains "$MAKE_GATE_PLAN" "make check" \
  "Static make gate plan must record make check verification."
require_contains "$MAILTO_ENCODING_PLAN" "Status: Completed" \
  "Mailto query encoding plan must record completed status."
require_contains "$MAILTO_ENCODING_PLAN" "make check" \
  "Mailto query encoding plan must record make check verification."
require_contains "$BUTTON_SAMPLE_PLAN" "Status: Completed" \
  "Button sample radius parameter plan must record completed status."
require_contains "$BUTTON_SAMPLE_PLAN" "make check" \
  "Button sample radius parameter plan must record make check verification."
require_contains "$DOCUMENT_REFERRER_PLAN" "Status: Completed" \
  "Document referrer policy plan must record completed status."
require_contains "$DOCUMENT_REFERRER_PLAN" "make check" \
  "Document referrer policy plan must record make check verification."
require_contains "$VIEWPORT_PLAN" "Status: Completed" \
  "Static viewport meta plan must record completed status."
require_contains "$VIEWPORT_PLAN" "make check" \
  "Static viewport meta plan must record make check verification."
require_contains "$CI_PLAN" "Status: Completed" \
  "Static CI baseline plan must record completed status."
require_contains "$CI_PLAN" "make check" \
  "Static CI baseline plan must record make check verification."
require_contains "$TWITTER_INTENT_PLAN" "Status: Completed" \
  "Static Twitter intent plan must record completed status."
require_contains "$TWITTER_INTENT_PLAN" "make check" \
  "Static Twitter intent plan must record make check verification."
require_contains "$KEYBOARD_FOCUS_PLAN" "Status: Completed" \
  "Static keyboard focus plan must record completed status."
require_contains "$KEYBOARD_FOCUS_PLAN" "make check" \
  "Static keyboard focus plan must record make check verification."

printf '%s\n' "Bootstrap.less static baseline checks passed."
