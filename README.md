# Bootstrap.less

Legacy static demo for the original Bootstrap.less mixins and variables.

## Project Shape

This repository has no package manager or build pipeline. The demo page loads:

- `index.html` for the documentation/demo page.
- `style.less` for page-specific styles.
- `bootstrap.less` for the mixins and variables.
- `less-1.1.3.min.js` as the checked-in browser LESS compiler.

## Verify

Run the SDK-free baseline check:

```sh
scripts/check-baseline.sh
```

For manual browser verification, serve the directory with any static file server
so `less-1.1.3.min.js` can fetch `style.less` over HTTP:

```sh
python3 -m http.server 8000
```

Then open `http://localhost:8000/`.

## Modernization Notes

The current baseline keeps the historical client-side LESS demo intact while
fixing valid HTML title markup and replacing insecure HTTP page links with
HTTPS. A future pass could add a deterministic LESS compilation step and commit
compiled CSS for browsers that no longer support the old runtime workflow well.
