#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
INDEX="$ROOT_DIR/index.html"

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
  "index.html" \
  "style.less" \
  "bootstrap.less" \
  "less-1.1.3.min.js"; do
  require_file "$path"
done

require_contains "index.html" "<title>Bootstrap.less</title>" \
  "index.html must contain a valid title tag."
require_contains "index.html" 'href="style.less"' \
  "index.html must load the demo LESS file."
require_contains "index.html" 'src="less-1.1.3.min.js"' \
  "index.html must load the checked-in LESS runtime."
require_contains "index.html" "less.watch();" \
  "index.html must preserve the browser LESS watch behavior."
require_contains "style.less" '@import "bootstrap.less";' \
  "style.less must import bootstrap.less."
require_contains "bootstrap.less" ".opacity(@opacity: 100)" \
  "bootstrap.less must preserve the opacity mixin signature."
require_contains "bootstrap.less" "opacity: @opacity / 100;" \
  "Opacity mixin must use its declared parameter for standard opacity."
require_contains "less-1.1.3.min.js" "LESS - Leaner CSS v1.1.3" \
  "LESS runtime provenance header is missing."
require_contains "README.md" "scripts/check-baseline.sh" \
  "README must document the baseline check."
require_contains "README.md" "make check" \
  "README must document the make check wrapper."
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
require_contains "README.md" "opacity mixin uses its declared parameter" \
  "README must document the opacity mixin fix."
require_file "Makefile"
require_contains "Makefile" "scripts/check-baseline.sh" \
  "Makefile must run the static baseline check."

if grep -Fq "http://" "$INDEX"; then
  printf '%s\n' "index.html must not contain insecure HTTP URLs." >&2
  exit 1
fi

if grep -Eq '@op([^[:alnum:]_-]|$)' "$ROOT_DIR/bootstrap.less"; then
  printf '%s\n' "bootstrap.less must not reference the undefined @op variable." >&2
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

printf '%s\n' "Bootstrap.less static baseline checks passed."
