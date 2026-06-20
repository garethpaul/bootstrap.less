#!/usr/bin/env node

const fs = require('node:fs/promises');
const path = require('node:path');
const { createRequire } = require('node:module');
const { TextDecoder } = require('node:util');

const MAX_INPUT_BYTES = 1024 * 1024;
const MAX_OUTPUT_BYTES = 2 * 1024 * 1024;
const PINNED_LESS_VERSION = '4.6.6';
const decoder = new TextDecoder('utf-8', { fatal: true });

async function resolveRoot(root) {
  const absoluteRoot = path.resolve(root);
  const metadata = await fs.lstat(absoluteRoot);

  if (metadata.isSymbolicLink() || !metadata.isDirectory()) {
    throw new Error('Repository root must be a real directory, not a symbolic link.');
  }

  return fs.realpath(absoluteRoot);
}

async function readBoundedRegularFile(root, filename, maximumBytes) {
  const filePath = path.join(root, filename);
  const metadata = await fs.lstat(filePath);

  if (metadata.isSymbolicLink()) {
    throw new Error(`${filename} must not be a symbolic link.`);
  }
  if (!metadata.isFile()) {
    throw new Error(`${filename} must be a regular file.`);
  }
  if (metadata.size > maximumBytes) {
    throw new Error(`${filename} exceeds its size limit of ${maximumBytes} bytes.`);
  }

  return fs.readFile(filePath);
}

function decodeUtf8(contents, filename) {
  try {
    return decoder.decode(contents);
  } catch {
    throw new Error(`${filename} must contain valid UTF-8.`);
  }
}

function validateImports(styleSource, bootstrapSource) {
  const styleWithoutComments = styleSource.replace(/\/\*[\s\S]*?\*\/|\/\/[^\r\n]*/g, '');
  const bootstrapWithoutComments = bootstrapSource.replace(
    /\/\*[\s\S]*?\*\/|\/\/[^\r\n]*/g,
    '',
  );
  const styleImports = styleWithoutComments.match(/@import\b/gi) || [];
  const approvedImports = styleWithoutComments.match(
    /^\s*@import\s+["']bootstrap\.less["'];\s*$/gim,
  ) || [];
  const bootstrapImports = bootstrapWithoutComments.match(/@import\b/gi) || [];

  if (styleImports.length !== 1 || approvedImports.length !== 1 || bootstrapImports.length !== 0) {
    throw new Error('Unapproved LESS import detected; only bootstrap.less may be imported.');
  }

  const combinedSource = `${styleWithoutComments}\n${bootstrapWithoutComments}`;
  if (/@plugin\b/i.test(combinedSource)) {
    throw new Error('Executable LESS plugins are not allowed.');
  }
  if (/\b(?:data-uri|image-size|image-width|image-height)\s*\(/i.test(combinedSource)) {
    throw new Error('File-reading LESS functions are not allowed.');
  }
}

function createRestrictedFilePlugin(lessCompiler, root, bootstrapSource) {
  const bootstrapPath = path.join(root, 'bootstrap.less');
  const fileManager = Object.assign(new lessCompiler.FileManager(), {
    supports: () => true,
    supportsSync: () => true,
    loadFile(filename, currentDirectory, options, environment, callback) {
      try {
        const result = this.loadFileSync(filename, currentDirectory, options, environment);
        if (callback) {
          callback(null, result);
          return undefined;
        }
        return Promise.resolve(result);
      } catch (error) {
        if (callback) {
          callback(error);
          return undefined;
        }
        return Promise.reject(error);
      }
    },
    loadFileSync(filename, currentDirectory, options = {}) {
      const requestedPath = path.resolve(currentDirectory, filename);
      if (requestedPath !== bootstrapPath) {
        throw new Error('LESS file access is restricted to bootstrap.less.');
      }
      return {
        contents: options.rawBuffer ? Buffer.from(bootstrapSource, 'utf8') : bootstrapSource,
        filename: bootstrapPath,
      };
    },
  });

  return {
    install(less, pluginManager) {
      pluginManager.addFileManager(fileManager);
    },
  };
}

async function compileCss(root, lessCompiler) {
  const repositoryRoot = await resolveRoot(root);
  const stylePath = path.join(repositoryRoot, 'style.less');
  const styleSource = decodeUtf8(
    await readBoundedRegularFile(repositoryRoot, 'style.less', MAX_INPUT_BYTES),
    'style.less',
  );
  const bootstrapSource = decodeUtf8(
    await readBoundedRegularFile(repositoryRoot, 'bootstrap.less', MAX_INPUT_BYTES),
    'bootstrap.less',
  );

  validateImports(styleSource, bootstrapSource);

  const result = await lessCompiler.render(styleSource, {
    disablePluginRule: true,
    filename: stylePath,
    javascriptEnabled: false,
    plugins: [createRestrictedFilePlugin(lessCompiler, repositoryRoot, bootstrapSource)],
  });
  const outputSize = Buffer.byteLength(result.css, 'utf8');

  if (outputSize > MAX_OUTPUT_BYTES) {
    throw new Error(`Generated CSS exceeds its size limit of ${MAX_OUTPUT_BYTES} bytes.`);
  }

  return result.css;
}

async function inspectOutput(root, required) {
  const outputPath = path.join(root, 'style.css');

  try {
    const metadata = await fs.lstat(outputPath);
    if (metadata.isSymbolicLink()) {
      throw new Error('style.css must not be a symbolic link.');
    }
    if (!metadata.isFile()) {
      throw new Error('style.css must be a regular file.');
    }
    if (metadata.size > MAX_OUTPUT_BYTES) {
      throw new Error(`style.css exceeds its size limit of ${MAX_OUTPUT_BYTES} bytes.`);
    }
    return { outputPath, mode: metadata.mode & 0o777 };
  } catch (error) {
    if (error.code === 'ENOENT' && !required) {
      return { outputPath, mode: 0o644 };
    }
    throw error;
  }
}

async function buildCss(root, lessCompiler) {
  const repositoryRoot = await resolveRoot(root);
  const output = await inspectOutput(repositoryRoot, false);
  const css = await compileCss(repositoryRoot, lessCompiler);
  const temporaryPath = path.join(
    repositoryRoot,
    `.style.css.${process.pid}.${Date.now()}.${Math.random().toString(16).slice(2)}.tmp`,
  );
  let temporaryFile;

  try {
    temporaryFile = await fs.open(temporaryPath, 'wx', output.mode);
    await temporaryFile.writeFile(css, 'utf8');
    await temporaryFile.sync();
    await temporaryFile.close();
    temporaryFile = undefined;
    await fs.rename(temporaryPath, output.outputPath);
  } finally {
    if (temporaryFile) {
      await temporaryFile.close().catch(() => {});
    }
    await fs.rm(temporaryPath, { force: true }).catch(() => {});
  }
}

async function checkGeneratedCss(root, lessCompiler) {
  const repositoryRoot = await resolveRoot(root);
  const output = await inspectOutput(repositoryRoot, true);
  const [expectedCss, checkedInCss] = await Promise.all([
    compileCss(repositoryRoot, lessCompiler),
    fs.readFile(output.outputPath, 'utf8'),
  ]);

  if (expectedCss !== checkedInCss) {
    throw new Error('Generated style.css does not match the checked-in LESS sources.');
  }
}

async function loadPinnedLess(root) {
  const repositoryRoot = await resolveRoot(root);
  const nodeModulesDirectory = path.join(repositoryRoot, 'node_modules');
  const nodeModulesMetadata = await fs.lstat(nodeModulesDirectory);
  if (nodeModulesMetadata.isSymbolicLink() || !nodeModulesMetadata.isDirectory()) {
    throw new Error('node_modules must be a real directory, not a symbolic link.');
  }

  const packageDirectory = path.join(repositoryRoot, 'node_modules', 'less');
  const packageMetadata = await fs.lstat(packageDirectory);

  if (packageMetadata.isSymbolicLink() || !packageMetadata.isDirectory()) {
    throw new Error('The repository-local LESS package must be a real directory.');
  }

  const packageRoot = await fs.realpath(packageDirectory);
  const packageJsonPath = path.join(packageRoot, 'package.json');
  const packageJson = JSON.parse(
    decodeUtf8(
      await readBoundedRegularFile(packageRoot, 'package.json', MAX_INPUT_BYTES),
      'node_modules/less/package.json',
    ),
  );
  if (packageJson.version !== PINNED_LESS_VERSION) {
    throw new Error(`Expected LESS ${PINNED_LESS_VERSION}, found ${packageJson.version}.`);
  }

  const requireFromRepository = createRequire(path.join(repositoryRoot, 'package.json'));
  const entryPath = await fs.realpath(requireFromRepository.resolve('less'));
  const relativeEntry = path.relative(packageRoot, entryPath);
  if (relativeEntry.startsWith('..') || path.isAbsolute(relativeEntry)) {
    throw new Error('LESS must resolve from the repository-local pinned package.');
  }

  return requireFromRepository('less');
}

async function main() {
  const [mode, ...extraArguments] = process.argv.slice(2);
  if (!['build', 'check', 'lint'].includes(mode) || extraArguments.length !== 0) {
    throw new Error('Usage: node scripts/build-css.js <build|check|lint>');
  }

  const root = path.resolve(__dirname, '..');
  const lessCompiler = await loadPinnedLess(root);

  if (mode === 'build') {
    await buildCss(root, lessCompiler);
  } else if (mode === 'check') {
    await checkGeneratedCss(root, lessCompiler);
  } else {
    await compileCss(root, lessCompiler);
  }
}

if (require.main === module) {
  main().catch((error) => {
    console.error(error.message);
    process.exitCode = 1;
  });
}

module.exports = {
  MAX_INPUT_BYTES,
  MAX_OUTPUT_BYTES,
  buildCss,
  checkGeneratedCss,
  compileCss,
  loadPinnedLess,
};
