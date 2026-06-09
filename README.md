# bootstrap.less

<!-- README-OVERVIEW-IMAGE -->
![Project overview](docs/readme-overview.svg)

## Overview

`garethpaul/bootstrap.less` is a static web project. Boostrap for Less

This README is based on the checked-in source, manifests, scripts, and repository metadata on the `master` branch. The project language mix found during review was: JavaScript (1), shell (1).

## Repository Contents

- `README.md` - project overview and local usage notes
- `docs` - source or example code
- `scripts` - source or example code
- `SECURITY.md` - security reporting and disclosure guidance
- `VISION.md` - project direction and maintenance guardrails

Additional scan context:

- Source directories: docs, scripts
- Dependency and build manifests: none detected
- Entry points or build surfaces: none detected
- Test-looking files: no obvious test files detected

## Getting Started

### Prerequisites

- Git

### Setup

```bash
git clone https://github.com/garethpaul/bootstrap.less.git
cd bootstrap.less
```

The setup commands above are derived from repository files. Legacy mobile, Python, or JavaScript samples may require older SDKs or package versions than a modern workstation uses by default.

## Running or Using the Project

Open `index.html` in a browser, or serve this directory with any static file server. The demo compiles `style.less` in the browser with the checked-in `less-1.1.3.min.js` runtime.

## Testing and Verification

Run the SDK-free source baseline and root wrapper gates:

```sh
make lint
make test
make build
make check
scripts/check-baseline.sh
```

This repository has no package manager and no build pipeline. The root `make build` target preserves the static preflight and reports that `index.html` is the runnable artifact. The source check verifies the local LESS runtime, the `style.less` import of `bootstrap.less`, HTTPS page URLs, safe `target="_blank"` links, and the single async Twitter widgets script load with a no-referrer policy.

When the required SDK or runtime is unavailable, use static checks and source review first, then verify on a machine that has the matching platform toolchain.

## Configuration and Secrets

- Detected references to Twitter. Keep API keys, OAuth credentials, tokens, and account-specific values in local configuration only.

## Security and Privacy Notes

- Review changes touching external API calls or credential-adjacent configuration; examples from the scan include index.html.
- Review changes touching network requests, sockets, or service endpoints; examples from the scan include bootstrap.less, index.html, less-1.1.3.min.js.
- Review changes touching file, media, JSON, XML, CSV, OCR, or data parsing; examples from the scan include bootstrap.less, index.html, less-1.1.3.min.js.
- Review changes touching shell execution, subprocess, or dynamic evaluation; examples from the scan include less-1.1.3.min.js.
- Review changes touching database, model, or persistence code; examples from the scan include bootstrap.less.

## Maintenance Notes

- The opacity mixin uses its declared parameter for all generated opacity rules.
- The Twitter widgets script is loaded once, asynchronously, with a
  `no-referrer` policy.
- Twitter share links also use a no-referrer policy before handing off to the
  external share endpoint.
- Root `make lint`, `make test`, `make build`, and `make check` keep the static
  source baseline available without introducing a package manager.
- See `SECURITY.md` for vulnerability reporting and safe research guidance.
- See `docs/plans/2026-06-09-static-make-gate-targets.md` for the root gate
  target baseline.
- See `VISION.md` for project direction and contribution guardrails.
- See `CHANGES.md` for the maintenance history.

## Contributing

Keep changes small and tied to the project that is already present in this repository. For code changes, document the toolchain used, avoid committing generated dependency directories or local configuration, and update this README when setup or verification steps change.
