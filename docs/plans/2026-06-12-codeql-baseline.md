---
title: CodeQL Baseline
date: 2026-06-12
status: completed
execution: code
---

# CodeQL Baseline

## Summary

Add pinned CodeQL analysis for GitHub Actions and the checked-in browser
JavaScript without changing the historical LESS 1.1.3 demo or page behavior.

## Requirements

- Analyze `actions` and `javascript-typescript` on pushes, pull requests,
  schedules, and manual dispatches using no-build mode.
- Keep immutable action pins, exact least-privilege permissions, non-persisted
  checkout credentials, bounded jobs, and superseded-run cancellation.
- Extend the static checker for workflow inventory, languages, pins,
  permissions, bypasses, documentation, and completed evidence.
- Preserve `index.html`, LESS sources, the checked-in LESS runtime, and the
  canonical Check workflow unchanged.
- Pass repository/external-working-directory checks, YAML parsing, hostile
  mutations, and exact-head hosted gates.

## Scope And Verification

This unit changes only the CodeQL workflow, checker contracts, guidance, and
evidence. It does not change browser markup, styling, scripts, or behavior.

## Work Completed

- Added pinned no-build CodeQL analysis for Actions and JavaScript/TypeScript.
- Kept exact permissions, credential-free checkout, bounded runtime, schedule,
  triggers, concurrency, language matrix, and action pins in a byte-for-byte
  checker contract.
- Preserved the static page, LESS sources, bundled runtime, and Check workflow.

## Verification Completed

- The untouched baseline passed from the repository and an external working directory.
- `make check` passed after implementation with the existing static-project
  test/build messages.
- Focused hostile mutations rejected language, pin, permission, credential,
  bypass, documentation, and incomplete-plan drift; all hostile mutations rejected.
- YAML parsing, shell syntax, `git diff --check`, and secret scanning passed.

## Hosted Verification

Exact-head Check and CodeQL evidence will be recorded after push. Tracker
reconciliation remains pending until both canonical events are terminal green.
