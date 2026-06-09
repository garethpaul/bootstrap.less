## Bootstrap.less Vision

This document explains the current state and direction of the project.
Project overview and developer docs: [`README.md`](README.md)

Bootstrap.less is a preserved LESS mixin and variable demo inspired by early
Bootstrap-era front-end tooling.

The repository contains an empty README, a demo `index.html`, `style.less`,
`bootstrap.less`, and a local Less.js runtime. The checked-in page documents the
available mixins and variables.

The goal is to keep the historical LESS demo readable while avoiding changes
that confuse it with modern Bootstrap.

The current focus is:

Priority:

- Preserve the LESS mixins, variables, and demo page
- Keep the project usable as a static local example
- Keep mixin parameters and generated CSS examples internally consistent
- Keep the only external script load constrained and documented
- Keep external share-link referrer behavior constrained and documented
- Keep static link attributes valid without relying on browser repair
- Keep root lint, test, and build gates tied to the static source baseline
- Make historical dependencies explicit
- Avoid modern CSS rewrites that erase the original learning value

Next priorities:

- Add concise README setup and project-history notes
- Fix obvious static-demo HTML issues when they block local viewing
- Document browser expectations for the bundled Less.js version
- Clarify attribution and relationship to early Bootstrap material

Contribution rules:

- One PR = one focused documentation, demo, or LESS change.
- Keep the static demo runnable without a build pipeline.
- Do not replace the project with modern Bootstrap assets.
- Preserve attribution comments and historical context.

## Security

Canonical security policy and reporting:

- [`SECURITY.md`](SECURITY.md)

This is a static front-end demo. Avoid adding external scripts, trackers, or
network dependencies unless they are documented and necessary for the demo.

## What We Will Not Merge (For Now)

- Modern Bootstrap migrations that discard the LESS sample
- Build pipelines that make the static demo harder to open
- Third-party scripts without a clear purpose
- Generated CSS artifacts unless a future workflow explicitly owns them

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
