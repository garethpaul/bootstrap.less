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
CODEQL_PLAN="docs/plans/2026-06-12-codeql-baseline.md"
LESS_ONE_TIME_PLAN="docs/plans/2026-06-13-static-less-one-time-compilation.md"
LESS_RUNTIME_INTEGRITY_PLAN="docs/plans/2026-06-13-static-less-runtime-integrity.md"
STATIC_CSS_BUILD_PLAN="docs/plans/2026-06-14-static-css-build-migration.md"
EXPECTED_WORKFLOW=$(mktemp "${TMPDIR:-/tmp}/bootstrap-less-workflow.XXXXXX")
trap 'rm -f "$EXPECTED_WORKFLOW"' EXIT HUP INT TERM

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
  "$CODEQL_PLAN" \
  "$LESS_ONE_TIME_PLAN" \
  "$LESS_RUNTIME_INTEGRITY_PLAN" \
  "$STATIC_CSS_BUILD_PLAN" \
  ".github/workflows/check.yml" \
  ".gitignore" \
  "SECURITY.md" \
  "index.html" \
  "package.json" \
  "package-lock.json" \
  "style.css" \
  "style.less" \
  "bootstrap.less"; do
  require_file "$path"
done

require_contains "index.html" "<title>Bootstrap.less</title>" \
  "index.html must contain a valid title tag."
require_contains "index.html" '<meta name="viewport" content="width=device-width, initial-scale=1">' \
  "index.html must include a mobile viewport baseline."
require_contains "index.html" '<link rel="stylesheet" type="text/css" media="all" href="style.css">' \
  "index.html must load the generated CSS artifact."
require_contains "index.html" '<meta name="referrer" content="no-referrer">' \
  "index.html must set a document-wide no-referrer policy."
require_contains "index.html" '<meta http-equiv="Content-Security-Policy" content="default-src '\''none'\''; style-src '\''self'\''; img-src '\''self'\''; base-uri '\''none'\''; form-action '\''none'\''">' \
  "index.html must enforce the approved script-free Content Security Policy."
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

skip_focus_rule=$(awk '/^a\.skip-link:focus \{$/,/^}$/' "$ROOT_DIR/style.less")
expected_skip_focus_rule='a.skip-link:focus {
  top: 20px;
  color: darken(@purple, 20);
  text-decoration: none;
}'
if [ "$skip_focus_rule" != "$expected_skip_focus_rule" ]; then
  printf '%s\n' "The focused skip link must use the approved visible-position rule." >&2
  exit 1
fi
if grep -Eiq '<script([[:space:]>])|javascript:' "$INDEX"; then
  printf '%s\n' "The static page must not execute project JavaScript." >&2
  exit 1
fi

if [ -e "$ROOT_DIR/less-1.1.3.min.js" ] || \
   grep -Eiq 'less-1\.1\.3|min\.js|stylesheet/less|window\.less|less\.watch' "$INDEX"; then
  printf '%s\n' "The legacy browser LESS runtime and runtime markup must remain removed." >&2
  exit 1
fi

if [ "$(grep -Foc 'href="style.css"' "$INDEX")" -ne 1 ] || \
   [ "$(grep -Ec '<link[[:space:]][^>]*rel="stylesheet"' "$INDEX")" -ne 1 ]; then
  printf '%s\n' "The page must load exactly one generated stylesheet." >&2
  exit 1
fi

if grep -Eh '#(flexbox|reset)[[:space:]]*>[[:space:]]*\.[[:alnum:]_-]+[[:space:]]*;' \
    "$ROOT_DIR/style.less" "$ROOT_DIR/bootstrap.less" | \
    grep -Ev '^[[:space:]]*//' >/dev/null; then
  printf '%s\n' "LESS namespace mixin calls must use explicit parentheses." >&2
  exit 1
fi

for package_contract in \
  '"private": true' \
  '"build": "lessc --no-color style.less style.css"' \
  '"check:generated": "lessc --no-color style.less | cmp - style.css"' \
  '"lint:less": "lessc --lint --no-color style.less"' \
  '"node": ">=20.19"' \
  '"less": "4.6.6"'; do
  require_contains "package.json" "$package_contract" \
    "package.json must preserve build contract: $package_contract"
done

require_contains "package-lock.json" '"lockfileVersion": 3' \
  "package-lock.json must use the current deterministic lockfile format."
require_contains "package-lock.json" '"node_modules/less"' \
  "package-lock.json must resolve the pinned LESS compiler."
require_contains ".gitignore" "node_modules/" \
  "Dependency installation artifacts must remain ignored."
require_contains "style.css" "a.skip-link:focus" \
  "Generated CSS must retain skip-link focus behavior."
require_contains "style.css" "@media (max-width: 700px)" \
  "Generated CSS must retain narrow-screen behavior."

for static_css_plan_contract in \
  "status: completed" \
  "## Status: Completed" \
  "make check" \
  "15 hostile mutations" \
  "headless Chrome" \
  "375px"; do
  require_contains "$STATIC_CSS_BUILD_PLAN" "$static_css_plan_contract" \
    "Static CSS build plan must record completed verification: $static_css_plan_contract"
done

for script_free_doc in "AGENTS.md" "README.md" "SECURITY.md" "VISION.md" "CHANGES.md"; do
  require_contains "$script_free_doc" "script-free" \
    "$script_free_doc must document the script-free deployment boundary."
done

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
require_contains "style.less" "overflow-x: auto;" \
  "Long code samples must contain their overflow on narrow screens."

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
require_contains "README.md" "npm ci --ignore-scripts --omit=optional" \
  "README must document the reduced frozen dependency install."
require_contains "README.md" "generated style.css" \
  "README must document the generated deployment stylesheet."
require_contains "README.md" "executes no project JavaScript" \
  "README must document the removed browser runtime boundary."
require_contains "README.md" "2026-06-14-static-css-build-migration.md" \
  "README must reference the static CSS build migration plan."
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
require_contains "Makefile" 'npm run lint:less' \
  "Makefile must run the modern LESS syntax gate."
require_contains "Makefile" 'npm run check:generated' \
  "Makefile must reject stale generated CSS."
require_contains "Makefile" 'npm run build' \
  "Makefile must expose the reproducible CSS build."
require_contains "Makefile" "lint:" \
  "Makefile must expose a lint gate."
require_contains "Makefile" "test:" \
  "Makefile must expose a test gate."
require_contains "Makefile" "build:" \
  "Makefile must expose a build gate."
require_contains "Makefile" "verify: lint test build" \
  "Makefile must expose a combined verify gate."
cat > "$EXPECTED_WORKFLOW" <<'EOF'
name: Check

on:
  push:
  pull_request:
  workflow_dispatch:

permissions:
  contents: read

concurrency:
  group: check-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  check:
    runs-on: ubuntu-24.04
    timeout-minutes: 5
    steps:
      - name: Check out repository
        uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10 # v6.0.3
        with:
          persist-credentials: false

      - name: Set up Node.js
        uses: actions/setup-node@48b55a011bda9f5d6aeb4c2d9c7362e8dae4041e # v6.4.0
        with:
          node-version: 24
          cache: npm

      - name: Install dependencies
        run: npm ci --ignore-scripts --omit=optional

      - name: Run baseline
        run: make check
EOF
if find "$ROOT_DIR/.github/workflows" -type f \( -name '*codeql*.yml' -o -name '*codeql*.yaml' \) -print -quit | grep -q .; then
  printf '%s\n' "GitHub default CodeQL setup must not be duplicated by an advanced workflow." >&2
  exit 1
fi

workflow_paths=$(find "$ROOT_DIR/.github/workflows" -type f \( -name '*.yml' -o -name '*.yaml' \) -print | sort)
expected_workflow_paths="$ROOT_DIR/.github/workflows/check.yml"
if [ "$workflow_paths" != "$expected_workflow_paths" ]; then
  printf '%s\n' "Only the canonical Check workflow is approved." >&2
  exit 1
fi
if ! cmp -s "$ROOT_DIR/.github/workflows/check.yml" "$EXPECTED_WORKFLOW"; then
  printf '%s\n' "GitHub Actions workflow must match the canonical credential-free baseline." >&2
  exit 1
fi
require_contains "$CODEQL_PLAN" "status: completed" \
  "CodeQL plan must record completed status."
require_contains "$CODEQL_PLAN" "make check" \
  "CodeQL plan must record make check verification."
require_contains "$CODEQL_PLAN" "external working directory" \
  "CodeQL plan must record location-independent verification."
require_contains "$CODEQL_PLAN" "hostile mutations rejected" \
  "CodeQL plan must record negative verification."
require_contains "$CODEQL_PLAN" "default setup" \
  "CodeQL plan must document the external configuration authority."
require_contains "$CODEQL_PLAN" "browser JavaScript remains uncovered" \
  "CodeQL plan must record the browser JavaScript analysis gap."
require_contains "README.md" "CodeQL default setup analyzes" \
  "README must document CodeQL coverage."
require_contains "SECURITY.md" "CodeQL default-setup results" \
  "SECURITY must document CodeQL triage."
require_contains "VISION.md" "CodeQL default-setup coverage" \
  "VISION must preserve CodeQL coverage."
require_contains "CHANGES.md" "CodeQL default setup" \
  "CHANGES must record CodeQL analysis."

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
