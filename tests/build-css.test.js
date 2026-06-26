const assert = require('node:assert/strict');
const fs = require('node:fs/promises');
const os = require('node:os');
const path = require('node:path');
const test = require('node:test');

const less = require('less');
const {
  MAX_INPUT_BYTES,
  MAX_OUTPUT_BYTES,
  MINIMUM_NODE_VERSION,
  buildCss,
  checkGeneratedCss,
  compileCss,
  assertSupportedNodeVersion,
  loadPinnedLess,
} = require('../scripts/build-css');

const repositoryRoot = path.resolve(__dirname, '..');

async function createFixture() {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), 'bootstrap-less-test-'));

  for (const filename of ['style.less', 'bootstrap.less', 'style.css']) {
    await fs.copyFile(
      path.join(repositoryRoot, filename),
      path.join(root, filename),
    );
  }

  return root;
}

test('compiler CLI enforces the documented Node runtime floor', () => {
  assert.equal(MINIMUM_NODE_VERSION, '20.19.0');
  assert.throws(() => assertSupportedNodeVersion('18.20.8'), /Node 20\.19 or newer/);
  assert.throws(() => assertSupportedNodeVersion('20.18.9'), /Node 20\.19 or newer/);
  assert.throws(() => assertSupportedNodeVersion('not-a-version'), /Unable to validate/);
  assert.doesNotThrow(() => assertSupportedNodeVersion('20.19.0'));
  assert.throws(() => assertSupportedNodeVersion('20.19.0-rc.1'), /release is required/);
  assert.doesNotThrow(() => assertSupportedNodeVersion('22.0.0'));
});

test('compiler output exactly matches the checked-in CSS', async () => {
  const css = await compileCss(repositoryRoot, less);
  const checkedInCss = await fs.readFile(path.join(repositoryRoot, 'style.css'), 'utf8');

  assert.equal(css, checkedInCss);
});

test('build refuses to follow a symlinked output', async (context) => {
  const root = await createFixture();
  context.after(() => fs.rm(root, { recursive: true, force: true }));
  const victim = path.join(root, 'victim.css');
  await fs.writeFile(victim, 'do not overwrite\n');
  await fs.rm(path.join(root, 'style.css'));
  await fs.symlink(victim, path.join(root, 'style.css'));

  await assert.rejects(buildCss(root, less), /style\.css.*symbolic link/i);
  assert.equal(await fs.readFile(victim, 'utf8'), 'do not overwrite\n');
});

test('compiler refuses a symlinked LESS input', async (context) => {
  const root = await createFixture();
  context.after(() => fs.rm(root, { recursive: true, force: true }));
  const externalInput = path.join(root, 'external.less');
  await fs.copyFile(path.join(root, 'style.less'), externalInput);
  await fs.rm(path.join(root, 'style.less'));
  await fs.symlink(externalInput, path.join(root, 'style.less'));

  await assert.rejects(compileCss(root, less), /style\.less.*symbolic link/i);
});

test('compiler binds LESS input validation and reads to one descriptor', async () => {
  const compilerSource = await fs.readFile(
    path.join(repositoryRoot, 'scripts', 'build-css.js'),
    'utf8',
  );

  assert.match(compilerSource, /constants\.O_RDONLY \| constants\.O_NOFOLLOW/);
  assert.match(compilerSource, /await fileHandle\.stat\(\)/);
  assert.match(compilerSource, /const contents = await fileHandle\.readFile\(\)/);
  assert.match(compilerSource, /contents\.byteLength > maximumBytes/);
  assert.match(compilerSource, /return contents/);
});

test('compiler rejects oversized LESS inputs before compilation', async (context) => {
  const root = await createFixture();
  context.after(() => fs.rm(root, { recursive: true, force: true }));
  await fs.writeFile(path.join(root, 'style.less'), Buffer.alloc(MAX_INPUT_BYTES + 1, 0x20));

  await assert.rejects(compileCss(root, less), /style\.less.*size limit/i);
});

test('compiler rejects oversized generated CSS', async (context) => {
  const root = await createFixture();
  context.after(() => fs.rm(root, { recursive: true, force: true }));
  const oversizedCompiler = {
    FileManager: less.FileManager,
    render: async () => ({ css: 'x'.repeat(MAX_OUTPUT_BYTES + 1) }),
  };

  await assert.rejects(compileCss(root, oversizedCompiler), /generated CSS.*size limit/i);
});

test('compiler rejects imports outside the two checked-in LESS files', async (context) => {
  const root = await createFixture();
  context.after(() => fs.rm(root, { recursive: true, force: true }));
  await fs.appendFile(path.join(root, 'style.less'), '\n@import "extra.less";\n');
  await fs.writeFile(path.join(root, 'extra.less'), '.escaped { color: red; }\n');

  await assert.rejects(compileCss(root, less), /unapproved LESS import/i);
});

test('compiler rejects LESS functions that read local files', async (context) => {
  const root = await createFixture();
  context.after(() => fs.rm(root, { recursive: true, force: true }));
  await fs.writeFile(path.join(root, 'secret.txt'), 'private fixture data\n');
  await fs.appendFile(
    path.join(root, 'style.less'),
    '\n.escape { background: data-uri("secret.txt"); }\n',
  );

  await assert.rejects(compileCss(root, less), /file-reading LESS functions are not allowed/i);
});

test('compiler file boundary survives URL strings before file reads', async (context) => {
  const root = await createFixture();
  context.after(() => fs.rm(root, { recursive: true, force: true }));
  await fs.writeFile(path.join(root, 'secret.txt'), 'private fixture data\n');
  await fs.appendFile(
    path.join(root, 'style.less'),
    '\n@safe-url: "https://example.com"; .escape { background: data-uri("secret.txt"); }\n',
  );

  await assert.rejects(compileCss(root, less), /LESS file access is restricted/i);
});

test('compiler rejects executable LESS plugins', async (context) => {
  const root = await createFixture();
  context.after(() => fs.rm(root, { recursive: true, force: true }));
  await fs.writeFile(
    path.join(root, 'plugin.js'),
    'registerPlugin({ install: function () {} });\n',
  );
  await fs.appendFile(path.join(root, 'style.less'), '\n@plugin "plugin.js";\n');

  await assert.rejects(compileCss(root, less), /LESS plugins are not allowed/i);
});

test('native plugin lockout survives URL strings before directives', async (context) => {
  const root = await createFixture();
  context.after(() => fs.rm(root, { recursive: true, force: true }));
  await fs.writeFile(
    path.join(root, 'plugin.js'),
    'registerPlugin({ install: function () {} });\n',
  );
  await fs.appendFile(
    path.join(root, 'style.less'),
    '\n@safe-url: "https://example.com"; @plugin "plugin.js";\n',
  );

  await assert.rejects(compileCss(root, less), /@plugin statements are not allowed/i);
});

test('compiler loader resolves the exact repository-local pinned package', async () => {
  const compiler = await loadPinnedLess(repositoryRoot);

  assert.equal(compiler.version.join('.'), '4.6.6');
});

test('compiler loader rejects a symlinked node_modules directory', async (context) => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), 'bootstrap-less-modules-'));
  context.after(() => fs.rm(root, { recursive: true, force: true }));
  await fs.copyFile(path.join(repositoryRoot, 'package.json'), path.join(root, 'package.json'));
  await fs.symlink(path.join(repositoryRoot, 'node_modules'), path.join(root, 'node_modules'));

  await assert.rejects(loadPinnedLess(root), /node_modules.*symbolic link/i);
});

test('package and Make gates route through the hardened compiler tests', async () => {
  const packageJson = JSON.parse(
    await fs.readFile(path.join(repositoryRoot, 'package.json'), 'utf8'),
  );
  const makefile = await fs.readFile(path.join(repositoryRoot, 'Makefile'), 'utf8');

  assert.equal(packageJson.scripts.build, 'node scripts/build-css.js build');
  assert.equal(packageJson.scripts['check:generated'], 'node scripts/build-css.js check');
  assert.equal(packageJson.scripts['lint:less'], 'node scripts/build-css.js lint');
  assert.equal(packageJson.scripts['test:build'], 'node --test tests/build-css.test.js');
  assert.match(makefile, /npm run test:build/);
});

test('workflow pins current official actions with read-only checkout', async () => {
  const workflow = await fs.readFile(
    path.join(repositoryRoot, '.github/workflows/check.yml'),
    'utf8',
  );

  assert.match(
    workflow,
    /actions\/checkout@9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0 # v7\.0\.0/,
  );
  assert.match(
    workflow,
    /actions\/setup-node@48b55a011bda9f5d6aeb4c2d9c7362e8dae4041e # v6\.4\.0/,
  );
  assert.match(workflow, /permissions:\n  contents: read/);
  assert.match(workflow, /persist-credentials: false/);
});

test('README describes precompiled CSS instead of browser compilation', async () => {
  const readme = await fs.readFile(path.join(repositoryRoot, 'README.md'), 'utf8');

  assert.doesNotMatch(
    readme,
    /Static viewing uses one-time production-mode LESS compilation/,
  );
  assert.match(readme, /Static viewing uses committed precompiled CSS/);
});

test('failed compilation preserves the existing generated CSS', async (context) => {
  const root = await createFixture();
  context.after(() => fs.rm(root, { recursive: true, force: true }));
  const output = path.join(root, 'style.css');
  const original = await fs.readFile(output, 'utf8');
  const failingCompiler = {
    FileManager: less.FileManager,
    render: async () => {
      throw new Error('synthetic compiler failure');
    },
  };

  await assert.rejects(buildCss(root, failingCompiler), /synthetic compiler failure/);
  assert.equal(await fs.readFile(output, 'utf8'), original);
  assert.deepEqual(
    (await fs.readdir(root)).filter((entry) => entry.startsWith('.style.css.')),
    [],
  );
});

test('generated CSS check rejects stale output', async (context) => {
  const root = await createFixture();
  context.after(() => fs.rm(root, { recursive: true, force: true }));
  await fs.appendFile(path.join(root, 'style.css'), '\n/* stale */\n');

  await assert.rejects(checkGeneratedCss(root, less), /does not match/i);
});

test('build replaces a regular output atomically with exact CSS', async (context) => {
  const root = await createFixture();
  context.after(() => fs.rm(root, { recursive: true, force: true }));
  await fs.writeFile(path.join(root, 'style.css'), 'stale\n');

  await buildCss(root, less);

  const expected = await compileCss(root, less);
  assert.equal(await fs.readFile(path.join(root, 'style.css'), 'utf8'), expected);
  assert.deepEqual(
    (await fs.readdir(root)).filter((entry) => entry.startsWith('.style.css.')),
    [],
  );
});
