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
require_contains "less-1.1.3.min.js" "LESS - Leaner CSS v1.1.3" \
  "LESS runtime provenance header is missing."
require_contains "README.md" "scripts/check-baseline.sh" \
  "README must document the baseline check."

if grep -Fq "http://" "$INDEX"; then
  printf '%s\n' "index.html must not contain insecure HTTP URLs." >&2
  exit 1
fi

if grep -F 'target="_blank"' "$INDEX" | grep -Fvq 'rel="noopener noreferrer"'; then
  printf '%s\n' "New-tab links must include rel=\"noopener noreferrer\"." >&2
  exit 1
fi

printf '%s\n' "Bootstrap.less static baseline checks passed."
