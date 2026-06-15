# bootstrap.less

<!-- README-OVERVIEW-IMAGE -->
![Project overview](docs/readme-overview.svg)

## Overview

`garethpaul/bootstrap.less` is a static web project. Boostrap for Less

This README is based on the checked-in source, manifests, scripts, and repository metadata on the `master` branch. The maintained source is LESS, generated CSS, HTML, POSIX shell, Make, and GitHub Actions YAML.

## Repository Contents

- `README.md` - project overview and local usage notes
- `docs` - source or example code
- `scripts` - source or example code
- `SECURITY.md` - security reporting and disclosure guidance
- `VISION.md` - project direction and maintenance guardrails

Additional scan context:

- Source directories: docs, scripts
- Dependency and build manifests: `package.json`, `package-lock.json`, and
  `Makefile`
- Entry points or build surfaces: `index.html`, `style.less`, and generated
  `style.css`
- Test-looking files: no obvious test files detected

## Getting Started

### Prerequisites

- Git
- Node.js 20.19 or newer
- npm 10 or newer

### Setup

```bash
git clone https://github.com/garethpaul/bootstrap.less.git
cd bootstrap.less
npm ci --ignore-scripts --omit=optional
```

The setup commands above are derived from repository files. Legacy mobile, Python, or JavaScript samples may require older SDKs or package versions than a modern workstation uses by default.

## Running or Using the Project

Open `index.html` in a browser, or serve this directory with any static file
server. The page loads the committed generated `style.css` and executes no
project JavaScript. Edit `style.less` or `bootstrap.less`, then run `make build`
to refresh the deployment stylesheet.

## Testing and Verification

Install the exact lockfile graph without lifecycle scripts, then run the source,
generated-output, and root wrapper gates:

```sh
npm ci --ignore-scripts --omit=optional
make lint
make test
make build
make check
scripts/check-baseline.sh
```

GitHub Actions runs `make check` through `.github/workflows/check.yml` on
pushes, pull requests, and manual dispatches. The workflow uses commit-pinned
checkout and Node setup actions, a frozen script-disabled install, read-only
repository access, and a bounded runtime. GitHub CodeQL default setup analyzes
GitHub Actions; the page itself now has no browser JavaScript analysis surface.

The repository pins LESS 4.6.6 and its transitive graph in `package-lock.json`;
the generated style.css file remains committed for direct static deployment.
Package scripts invoke that repository-local compiler directly and fail when
the frozen install is absent instead of falling back to an ambient `lessc`.
The Make wrapper derives its root from the loaded repository Makefile and
cannot be redirected with a caller-supplied ROOT value.
The install omits compiler features declared optional by LESS because this
project compiles local files without URL fetching, image inspection, or source
maps.
`make lint` checks modern LESS syntax, `make test` rejects drift between the
LESS sources and generated `style.css`, and `make build` refreshes that
artifact. The dependency-free source check also enforces the script-free
Content Security Policy, HTTPS page URLs, safe `target="_blank"` links, the
document-wide no-referrer policy, keyboard skip navigation, visible focus
states, responsive layout, and user-triggered Twitter sharing with no automatic
third-party script requests.
Loading the page makes no automatic third-party script requests.

When the required SDK or runtime is unavailable, use static checks and source review first, then verify on a machine that has the matching platform toolchain.

## Configuration and Secrets

- Detected references to Twitter. Keep API keys, OAuth credentials, tokens, and account-specific values in local configuration only.

## Security and Privacy Notes

- Review changes touching external API calls or credential-adjacent configuration; examples from the scan include index.html.
- Review changes touching network requests or external endpoints in
  `index.html`.
- Review dependency and build changes in `package.json`, `package-lock.json`,
  `Makefile`, and `.github/workflows/check.yml` together.
- Keep generated `style.css` synchronized with `style.less` and
  `bootstrap.less`; do not hand-edit the generated artifact.
- Review changes touching database, model, or persistence code; examples from the scan include bootstrap.less.

## Maintenance Notes

- The opacity mixin uses its declared parameter for all generated opacity rules.
- Twitter sharing uses self-contained Web Intent links, so loading the page does
  not contact the Twitter widgets runtime.
- The page sets a document-wide no-referrer policy before loading styles or
  outbound links.
- The page includes a mobile viewport meta tag so static local viewing starts
  from the device width instead of a desktop layout default.
- Twitter share links also use a no-referrer policy, isolated new tabs, encoded
  query parameters, and descriptive link text before handing off to the
  external share endpoint.
- The page bounds its historical 640px layout and stacks the overview grid on
  narrow screens so headings, links, and columns remain visible. Long code
  samples scroll within their own block instead of widening the page.
- Mailto query strings stay URL-encoded so static links remain valid.
- The visible button snippet uses its declared border radius parameter, matching
  the checked-in `.button()` mixin.
- The long reference page starts with a keyboard-accessible skip link targeting
  its single focusable `main` landmark, and links keep a visible focus outline.
- LESS 4.6.6 compiles the maintained sources into committed `style.css`; the
  page executes no project JavaScript and enforces a script-free CSP.
- See `docs/plans/2026-06-14-static-css-build-migration.md` for the generated CSS
  build and runtime-removal contract.
- Static viewing uses one-time production-mode LESS compilation instead of the
  development watch loop, avoiding lifetime polling after the initial render.
- Root `make lint`, `make test`, `make build`, and `make check` keep the static
  source baseline available without introducing a package manager, including
  when invoked outside the repository root with `make -f`.
- See `SECURITY.md` for vulnerability reporting and safe research guidance.
- See `docs/plans/2026-06-09-static-make-gate-targets.md` for the root gate
  target baseline.
- See `docs/plans/2026-06-09-static-mailto-query-encoding.md` for the mailto
  link encoding guard.
- See `docs/plans/2026-06-09-static-button-sample-radius-parameter.md` for the
  button snippet radius parameter guard.
- See `docs/plans/2026-06-09-static-document-referrer-policy.md` for the
  page-level referrer policy guard.
- See `docs/plans/2026-06-09-static-viewport-meta-baseline.md` for the mobile
  viewport meta baseline.
- See `docs/plans/2026-06-10-ci-baseline.md` for the GitHub Actions baseline.
- See `docs/plans/2026-06-10-static-twitter-intent-links.md` for the
  user-triggered share-link and third-party script removal.
- See `docs/plans/2026-06-13-static-less-one-time-compilation.md` for the
  production-mode client-side compilation boundary.
- See `docs/plans/2026-06-13-static-less-runtime-integrity.md` for the vendored
  LESS runtime Subresource Integrity boundary.
- See `VISION.md` for project direction and contribution guardrails.
- See `CHANGES.md` for the maintenance history.

## Contributing

Keep changes small and tied to the project that is already present in this repository. For code changes, document the toolchain used, avoid committing generated dependency directories or local configuration, and update this README when setup or verification steps change.
