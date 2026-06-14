---
title: Local LESS Compiler Gate
type: reliability
status: in_progress
date: 2026-06-14
---

# Local LESS Compiler Gate

## Status: In Progress

## Problem Frame

The generated CSS gate declares LESS 4.6.6 in the frozen package graph, but its
package scripts invoke the bare `lessc` command. When `node_modules` is absent,
npm can resolve an unrelated compiler from the ambient `PATH`; LESS 2.7.2 then
reports false generated-output drift instead of identifying the missing pinned
install. This weakens the reproducibility boundary and makes local validation
depend on workstation state.

## Prioritized Engineering Tasks

1. Resolve the compiler through the repository-local pinned package path.
2. Fail clearly when dependencies have not been installed instead of accepting
   an ambient global compiler.
3. Add static contracts that reject bare or global `lessc` command resolution.
4. Reinstall the frozen graph and prove lint, generated freshness, build, and
   full repository gates with the exact compiler.

## Scope Boundaries

- Preserve LESS sources and the byte-for-byte generated `style.css` artifact.
- Preserve the frozen LESS 4.6.6 dependency graph and reduced install command.
- Do not add runtime JavaScript, a bundler, or a new dependency.
- Do not merge or close any pull request without explicit owner authorization.

## Verification Plan

- Run the dependency-free static baseline before installing packages.
- Run `npm ci --ignore-scripts --omit=optional` and verify LESS 4.6.6 locally.
- Run `make check`, `make verify`, and an external-working-directory check.
- Mutate the local compiler commands and static contracts independently and
  require each weakened variant to fail.
- Audit the exact diff, generated artifacts, and credential-shaped text before
  committing only intended paths.
