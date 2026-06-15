# Make Root Override Protection

## Status: Planned

## Context

The Makefile derives `ROOT` from its own path with a regular assignment. GNU
Make command-line variables take precedence over that assignment, so
`make ROOT=/tmp check` redirects the trusted checker, local compiler, generated
CSS comparison, and build working directory outside the repository.

## Priority

High verification integrity. Public Make targets must always execute the
reviewed repository files regardless of caller-supplied variables.

## Requirements

- Protect the repository-derived Make root from command-line overrides.
- Preserve repository-root and external-working-directory behavior.
- Preserve the pinned local LESS compiler and generated CSS equality checks.
- Add a fail-closed contract for the protected root declaration.
- Prove a hostile `ROOT=/tmp` assignment cannot redirect dry-run commands.

## Scope Boundaries

- Do not change LESS source, generated CSS, page markup, dependencies,
  workflow events, or browser behavior.
- Do not introduce global compiler fallbacks or network installs.
- Do not merge or close stacked pull requests without explicit authorization.

## Implementation Units

1. Change the Make root declaration to a protected repository-derived value.
2. Extend the baseline checker and maintained build documentation.
3. Record completed repository, external-directory, hostile-override, and
   mutation verification evidence.

## Verification

- focused shell and baseline validation
- repository and external-directory `make check`
- hostile `ROOT=/tmp` dry-run path audit
- hostile protected-root, documentation, and completed-plan mutations
- generated CSS equality, package lock, artifact, credential-pattern, and
  exact-diff audits

## Remaining Risks

- Browser interaction and external Twitter endpoint behavior remain outside the
  dependency-free local gate.
