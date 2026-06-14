# AGENTS.md

## Repository purpose

`garethpaul/bootstrap.less` is a static web project. Boostrap for Less

## Project structure

- `Makefile` - repository build and verification targets
- `package.json` and `package-lock.json` - pinned LESS compiler graph
- `style.less` and `bootstrap.less` - maintained stylesheet sources
- `style.css` - generated deployment stylesheet; do not hand-edit
- `scripts` - baseline checks and helper scripts
- `docs` - plans, notes, and generated README assets

## Development commands

- Install dependencies: `npm ci --ignore-scripts --omit=optional`
- Full baseline: `make check`
- Combined verification: `make verify`
- Lint/static checks: `make lint`
- Tests: `make test`
- Build: `make build`
- If a command above skips because a platform toolchain is missing, verify on a machine with that SDK before claiming platform behavior is tested.

## Coding conventions

- Use explicit parentheses for namespace mixin calls so LESS 4.6.6 compiles
  without deprecation warnings.
- Package scripts must resolve LESS through `node_modules`; never fall back to
  an ambient or global `lessc` executable.
- Keep generated `style.css` byte-for-byte synchronized with the LESS sources.

## Testing guidance

- No dedicated test files were detected; treat `make check` as the minimum baseline.
- Start with the narrowest relevant test or Make target, then run `make check` before handing off if the change is not documentation-only.
- Keep README verification notes in sync when commands, fixtures, or supported toolchains change.

## PR / change guidance

- Keep diffs focused on the requested repository and avoid unrelated modernization or formatting churn.
- Preserve public APIs, sample behavior, file formats, and documented environment variables unless the task explicitly changes them.
- Update tests, README notes, or docs/plans when behavior, security posture, or validation commands change.
- Call out skipped platform validation, legacy toolchain assumptions, and any risky files touched in the final summary.

## Safety and gotchas

- Detected references to Twitter. Keep API keys, OAuth credentials, tokens, and account-specific values in local configuration only.
- The opacity mixin uses its declared parameter for all generated opacity rules.
- The page executes no project JavaScript and must keep its script-free Content
  Security Policy.
- The page sets a document-wide no-referrer policy before loading styles or
  outbound links.
- Twitter share links also use a no-referrer policy before handing off to the external share endpoint.
- Mailto query strings stay URL-encoded so static links remain valid.
- Long code samples contain horizontal overflow instead of widening the mobile
  document.

## Agent workflow

1. Inspect the README, Makefile, manifests, and the files directly related to the request.
2. Make the smallest source or docs change that satisfies the task; regenerate
   `style.css` when LESS sources change, but avoid dependency directories and
   local-environment files.
3. Run the narrowest useful validation first, then `make check` or the documented package/platform gate when available.
4. If a required SDK, service credential, or external runtime is unavailable, record the skipped command and why.
5. Summarize changed files, commands run, and remaining risks or follow-up validation.
