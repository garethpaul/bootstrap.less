---
title: CodeQL Baseline
date: 2026-06-12
status: completed
execution: code
---

# CodeQL Baseline

## Summary

Document and guard the repository's existing GitHub CodeQL default setup for
Actions without changing the historical LESS 1.1.3 demo or page behavior.

## Requirements

- Preserve GitHub default setup analysis for `actions` as the repository-owned
  external security setting.
- Do not add an advanced CodeQL workflow while default setup is active because
  GitHub rejects the conflicting configuration modes.
- Extend the static checker to reject extra and advanced CodeQL workflows and
  require truthful documentation of the browser JavaScript analysis gap.
- Preserve `index.html`, LESS sources, the checked-in LESS runtime, and the
  canonical Check workflow unchanged.
- Pass repository/external-working-directory checks, YAML parsing, hostile
  mutations, and exact-head hosted gates.

## Scope And Verification

This unit changes only checker contracts, guidance, and evidence. It does not
change browser markup, styling, scripts, or behavior.

## Work Completed

- Recorded that GitHub default setup analyzes Actions.
- Removed the conflicting advanced workflow after its Actions and JavaScript
  jobs failed while the default-setup Actions job succeeded.
- Recorded that browser JavaScript remains uncovered; the failed advanced job
  did not establish JavaScript coverage.
- Preserved the static page, LESS sources, bundled runtime, and Check workflow.

## Verification Completed

- The untouched baseline passed from the repository and an external working directory.
- `make check` passed after implementation with the existing static-project
  test/build messages.
- Focused hostile mutations rejected duplicate CodeQL and extra workflows,
  documentation drift, missing JavaScript-gap evidence, and incomplete-plan
  drift; all hostile mutations rejected.
- YAML parsing, shell syntax, `git diff --check`, and secret scanning passed.

## Hosted Verification

On head `af3a97e906037f9ecef910aa16e8ba3e0ad34eb3`, push and pull-request
Check runs `27442002734` and `27442005816` succeeded. Default-setup Actions
job `81118069693` succeeded, while duplicate advanced run `27442005884`
failed for Actions and JavaScript/TypeScript. Exact-head replacement evidence
remains pending after the conflicting workflow removal.
