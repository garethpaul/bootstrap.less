# LESS Input Descriptor Boundary

## Status: Completed

## Problem

The compiler wrapper rejected an input when `lstat` observed a symlink, but it
then reopened the pathname with `readFile`. A concurrent replacement between
those operations could make validation describe one filesystem object while
compilation consumed another, including a symlink outside the checkout.

## Design

- Open each bounded input once with `O_RDONLY | O_NOFOLLOW`.
- Inspect regular-file metadata through `FileHandle.stat()`.
- Read through the same `FileHandle` and recheck the actual byte count.
- Close the descriptor on every success and failure path.
- Preserve existing UTF-8, import, plugin, local-file, generated-size, and
  atomic-output behavior.

## Alternatives

- Repeating `lstat` after a pathname read still leaves another check/use gap.
- Comparing inode metadata before and after a pathname read detects some races
  only after unreviewed bytes have already been consumed.
- Copying inputs to temporary paths adds another pathname boundary and more
  cleanup without improving on descriptor ownership.

## Scope Boundaries

- Do not change LESS source, generated CSS, dependency versions, import policy,
  output replacement, page behavior, or supported Node releases.

## Work Completed

- Replaced pathname-based input reads with no-follow descriptor ownership.
- Added a focused source contract covering descriptor open, metadata, read,
  actual-size enforcement, and return behavior.
- Updated baseline, security, roadmap, agent, changelog, and README guidance.

## Verification Completed

- The focused descriptor contract failed before implementation because the
  wrapper used `lstat` followed by `fs.readFile(filePath)`.
- The focused descriptor, symlink rejection, and oversized-input tests pass.
- All 20 build-boundary tests pass on Node 20.20.2, 22.16.0, and 24.17.0.
- `make check` passes on all three supported runtimes and through an absolute
  Makefile path from outside the repository.
- Static baseline, LESS compilation, generated CSS fidelity, atomic build, and
  shell syntax checks pass.
- Restoring the `lstat` plus pathname `readFile` implementation makes the
  focused descriptor contract fail.
