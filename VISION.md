## Bootstrap.less Vision

This document explains the current state and direction of the project.
Project overview and developer docs: [`README.md`](README.md)

Bootstrap.less is a preserved LESS mixin and variable demo inspired by early
Bootstrap-era front-end tooling.

The repository contains a demo `index.html`, maintained `style.less` and
`bootstrap.less` sources, and generated `style.css`. The checked-in page
documents the available mixins and variables without executing JavaScript.

The goal is to keep the historical LESS demo readable while avoiding changes
that confuse it with modern Bootstrap.

The current focus is:

Priority:

- Preserve the LESS mixins, variables, and demo page
- Keep the project usable as a static local example
- Compile LESS with the pinned current compiler before deployment
- Keep generated CSS synchronized with its reviewed LESS sources
- Keep the deployed page script-free under a restrictive Content Security Policy
- Keep mixin parameters and generated CSS examples internally consistent
- Keep visible demo snippets aligned with checked-in mixin signatures
- Avoid automatic third-party script requests from the static page
- Keep document-wide referrer behavior constrained and documented
- Keep local static viewing usable on mobile-width browsers
- Keep the historical grid readable without horizontal page overflow
- Keep long code samples contained without horizontal document overflow
- Keep external share-link referrer behavior constrained and documented
- Keep external sharing explicit and user-triggered through ordinary links
- Keep the long reference page navigable by keyboard and document landmarks
- Keep static link attributes valid without relying on browser repair
- Keep root lint, test, and build gates tied to the static source baseline
- Keep GitHub Actions running the static `make check` baseline before review
- Keep CodeQL default-setup coverage for Actions and avoid reintroducing a browser JavaScript surface
- Make historical dependencies explicit
- Avoid modern CSS rewrites that erase the original learning value

Next priorities:

- Add concise README setup and project-history notes
- Fix obvious static-demo HTML issues when they block local viewing
- Document generated CSS review and deployment expectations
- Clarify attribution and relationship to early Bootstrap material

Contribution rules:

- One PR = one focused documentation, demo, or LESS change.
- Keep the static demo directly runnable from committed generated CSS.
- Keep `.github/workflows/check.yml` aligned with the frozen dependency install
  and generated-output gate.
- Keep build commands bound to the repository-local locked LESS compiler.
- Keep Make verification rooted to the loaded repository Makefile.
- Do not replace the project with modern Bootstrap assets.
- Preserve attribution comments and historical context.

## Security

Canonical security policy and reporting:

- [`SECURITY.md`](SECURITY.md)

This is a static front-end demo. Avoid adding external scripts, trackers, or
network dependencies unless they are documented and necessary for the demo.

## What We Will Not Merge (For Now)

- Modern Bootstrap migrations that discard the LESS sample
- Build pipelines that require a runtime server or uncommitted deployment assets
- Third-party scripts without a clear purpose
- Hand-edited generated CSS or unreviewed dependency updates

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
