#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
INDEX="$ROOT_DIR/index.html"
MAKE_GATE_PLAN="docs/plans/2026-06-09-static-make-gate-targets.md"
MAILTO_ENCODING_PLAN="docs/plans/2026-06-09-static-mailto-query-encoding.md"
BUTTON_SAMPLE_PLAN="docs/plans/2026-06-09-static-button-sample-radius-parameter.md"
DOCUMENT_REFERRER_PLAN="docs/plans/2026-06-09-static-document-referrer-policy.md"
VIEWPORT_PLAN="docs/plans/2026-06-09-static-viewport-meta-baseline.md"

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
require_contains "index.html" "less.watch();" \
  "index.html must preserve the browser LESS watch behavior."
require_contains "index.html" 'href="mailto:hi@markdotto.com?subject=About%20Bootstrap"' \
  "Mailto query strings must be URL-encoded."
require_contains "style.less" '@import "bootstrap.less";' \
  "style.less must import bootstrap.less."
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
require_contains "README.md" "no package manager and no build pipeline" \
  "README must document the no-build project shape."
require_contains "README.md" "less-1.1.3.min.js" \
  "README must document the checked-in LESS runtime."
require_contains "README.md" "CHANGES.md" \
  "README must point to CHANGES.md."
require_contains "README.md" "single async Twitter widgets script load" \
  "README must document the Twitter widgets script baseline."
require_contains "README.md" "no-referrer policy" \
  "README must document the Twitter widgets referrer policy."
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
require_file "Makefile"
require_contains "Makefile" "scripts/check-baseline.sh" \
  "Makefile must run the static baseline check."
require_contains "Makefile" "lint:" \
  "Makefile must expose a lint gate."
require_contains "Makefile" "test:" \
  "Makefile must expose a test gate."
require_contains "Makefile" "build:" \
  "Makefile must expose a build gate."
require_contains "Makefile" "verify: lint test build" \
  "Makefile must expose a combined verify gate."

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

TWITTER_WIDGET_COUNT=$(grep -Foc 'src="https://platform.twitter.com/widgets.js"' "$INDEX")
if [ "$TWITTER_WIDGET_COUNT" -ne 1 ]; then
  printf '%s\n' "index.html must load the Twitter widgets script exactly once." >&2
  exit 1
fi

if grep -F 'href="https://twitter.com/share"' "$INDEX" | grep -Fvq 'referrerpolicy="no-referrer"'; then
  printf '%s\n' "Twitter share links must not send a referrer." >&2
  exit 1
fi

require_contains "index.html" '<script type="text/javascript" async referrerpolicy="no-referrer" src="https://platform.twitter.com/widgets.js"></script>' \
  "Twitter widgets script must load asynchronously without sending a referrer."
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

printf '%s\n' "Bootstrap.less static baseline checks passed."
