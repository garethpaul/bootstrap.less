# Node Runtime Enforcement Design

## Problem

`package.json` declared Node `>=20.19`, but npm only emitted an engine warning
under Node 18 and `make check` still completed successfully. That allowed an
unsupported runtime to produce misleading validation evidence for the LESS
compiler pipeline.

## Options

1. Rely on contributors to notice npm's warning. This is the existing
   fail-open behavior.
2. Require a machine-specific npm `engine-strict` setting. This is not
   repository-controlled and is easy to omit.
3. Validate `process.versions.node` inside the compiler CLI before loading the
   LESS package.

## Decision

Use option 3. Keep the predicate pure and unit-testable, reject malformed,
older, or prerelease versions, and accept stable Node 20.19 plus newer major
releases. The repository baseline pins both the function and its CLI invocation.
