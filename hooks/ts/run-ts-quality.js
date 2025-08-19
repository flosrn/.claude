#!/usr/bin/env bun

/**
 * Claude Code TypeScript Quality Hook - Strict Version
 * 
 * Inspired by bartolli/claude-code-typescript-hooks
 * Adapted for Florian's strict TypeScript requirements:
 * - Blocks `any` and `unknown` types completely
 * - Strict TypeScript compilation 
 * - Targets only modified files for performance
 * - Uses Bun for speed
 * - Cache system for fast repeated runs
 */

import { execSync } from 'child_process';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import { resolve, dirname } from 'path';
import { createHash } from 'crypto';

class StrictTypeScriptQualityHook {
  constructor() {
    this.cacheFile = resolve(dirname(import.meta.path), 'quality-cache.json');
    this.repoRoot = null;
    this.modifiedFiles = [];
    this.debug = process.env.CLAUDE_HOOKS_DEBUG === 'true';
  }

  log(level, message, ...args) {
    if (level === 'debug' && !this.debug) return;
    
    const prefix = {
      debug: '[DEBUG]',
      info: '[INFO]',
      warn: '[WARN]', 
      error: '[ERROR]',
      ok: '[OK]'
    }[level] || '[LOG]';
    
    console.error(`${prefix} ${message}`, ...args);
  }

  findRepoRoot() {
    if (this.repoRoot) return this.repoRoot;
    
    try {
      this.repoRoot = execSync('git rev-parse --show-toplevel', { 
        encoding: 'utf8',
        stdio: ['ignore', 'pipe', 'ignore']
      }).trim();
      this.log('debug', `Found repo root: ${this.repoRoot}`);
      return this.repoRoot;
    } catch (error) {
      // Fallback to current directory if not in git repo
      this.repoRoot = process.cwd();
      this.log('debug', `Not in git repo, using cwd: ${this.repoRoot}`);
      return this.repoRoot;
    }
  }

  getModifiedFiles() {
    // Get files from CLAUDE_FILE_PATHS env var
    const claudeFiles = process.env.CLAUDE_FILE_PATHS;
    if (claudeFiles) {
      const files = claudeFiles.split(' ').filter(f => f.trim());
      this.log('debug', `Files from CLAUDE_FILE_PATHS: ${files.join(', ')}`);
      return files.filter(f => f.match(/\.(ts|tsx)$/));
    }
    
    this.log('debug', 'No CLAUDE_FILE_PATHS found');
    return [];
  }

  loadCache() {
    if (!existsSync(this.cacheFile)) {
      this.log('debug', 'No cache file found');
      return { hashes: {}, configPath: null };
    }
    
    try {
      const cache = JSON.parse(readFileSync(this.cacheFile, 'utf8'));
      this.log('debug', `Loaded cache: ${Object.keys(cache.hashes || {}).length} entries`);
      return cache;
    } catch (error) {
      this.log('debug', `Cache read error: ${error.message}`);
      return { hashes: {}, configPath: null };
    }
  }

  saveCache(cache) {
    try {
      writeFileSync(this.cacheFile, JSON.stringify(cache, null, 2));
      this.log('debug', 'Cache saved');
    } catch (error) {
      this.log('debug', `Cache save error: ${error.message}`);
    }
  }

  findTSConfig(filePath = null) {
    // If we have a specific file, find the closest tsconfig
    if (filePath && existsSync(filePath)) {
      const closestConfig = this.findClosestTSConfig(filePath);
      if (closestConfig) {
        this.log('debug', `Found closest tsconfig: ${closestConfig}`);
        return closestConfig;
      }
    }

    // Fallback to repo root logic
    const repoRoot = this.findRepoRoot();
    const candidates = [
      resolve(repoRoot, 'tsconfig.json'),
      resolve(repoRoot, 'tsconfig.build.json'),
      resolve(process.cwd(), 'tsconfig.json')
    ];

    for (const candidate of candidates) {
      if (existsSync(candidate)) {
        this.log('debug', `Found fallback tsconfig: ${candidate}`);
        return candidate;
      }
    }

    this.log('debug', 'No tsconfig found');
    return null;
  }

  findClosestTSConfig(filePath) {
    // "Find up" algorithm - like TypeScript does
    let currentDir = dirname(resolve(filePath));
    const repoRoot = this.findRepoRoot();

    while (currentDir !== dirname(currentDir)) { // Until filesystem root
      const candidates = [
        resolve(currentDir, 'tsconfig.json'),
        resolve(currentDir, 'tsconfig.build.json')
      ];

      for (const candidate of candidates) {
        if (existsSync(candidate)) {
          this.log('debug', `Found tsconfig via find-up: ${candidate}`);
          return candidate;
        }
      }

      // Stop at repo root if we reach it
      if (currentDir === repoRoot) {
        this.log('debug', 'Reached repo root, stopping find-up');
        break;
      }

      currentDir = dirname(currentDir);
    }

    return null;
  }

  getConfigHash(configPath) {
    if (!configPath || !existsSync(configPath)) return null;
    
    try {
      const content = readFileSync(configPath, 'utf8');
      return createHash('sha256').update(content).digest('hex');
    } catch (error) {
      this.log('debug', `Config hash error: ${error.message}`);
      return null;
    }
  }

  async runPrettier(files) {
    if (!files.length) return { success: true, output: '' };
    
    try {
      // Try project prettier first, then global
      let prettierCmd;
      const repoRoot = this.findRepoRoot();
      
      if (existsSync(resolve(repoRoot, 'node_modules', '.bin', 'prettier'))) {
        prettierCmd = resolve(repoRoot, 'node_modules', '.bin', 'prettier');
      } else {
        prettierCmd = 'prettier';
      }
      
      const fileArgs = files.map(f => `"${f}"`).join(' ');
      const cmd = `${prettierCmd} --write ${fileArgs}`;
      
      this.log('debug', `Running prettier: ${cmd}`);
      
      const output = execSync(cmd, { 
        encoding: 'utf8',
        cwd: repoRoot,
        stdio: ['ignore', 'pipe', 'pipe']
      });
      
      this.log('info', `Prettier formatted ${files.length} files`);
      return { success: true, output };
      
    } catch (error) {
      this.log('debug', `Prettier error: ${error.message}`);
      return { success: false, output: error.message };
    }
  }

  async runESLint(files) {
    if (!files.length) return { success: true, output: '', hasErrors: false };
    
    try {
      const repoRoot = this.findRepoRoot();
      
      // Check if we're in a Turborepo project
      const turboConfigPath = resolve(repoRoot, 'turbo.json');
      const hasTurbo = existsSync(turboConfigPath);
      
      if (hasTurbo) {
        // Use Turbo for ESLint in monorepo
        const packageJsonPath = this.findPackageJson(files[0]);
        if (packageJsonPath) {
          const packageJson = JSON.parse(readFileSync(packageJsonPath, 'utf8'));
          const packageName = packageJson.name;
          
          if (packageName) {
            const cmd = `pnpm turbo lint --filter=${packageName} --force`;
            
            this.log('debug', `Running Turbo ESLint: ${cmd}`);
            
            const output = execSync(cmd, { 
              encoding: 'utf8',
              cwd: repoRoot,
              stdio: ['ignore', 'pipe', 'pipe']
            });
            
            this.log('info', `Turbo ESLint passed for ${files.length} files`);
            return { success: true, output, hasErrors: false };
          }
        }
      }
      
      // Fallback to direct eslint
      let eslintCmd;
      if (existsSync(resolve(repoRoot, 'node_modules', '.bin', 'eslint'))) {
        eslintCmd = resolve(repoRoot, 'node_modules', '.bin', 'eslint');
      } else {
        eslintCmd = 'eslint';
      }
      
      const fileArgs = files.map(f => `"${f}"`).join(' ');
      const cmd = `${eslintCmd} --fix --max-warnings=0 ${fileArgs}`;
      
      this.log('debug', `Running ESLint: ${cmd}`);
      
      const output = execSync(cmd, { 
        encoding: 'utf8',
        cwd: repoRoot,
        stdio: ['ignore', 'pipe', 'pipe']
      });
      
      this.log('info', `ESLint passed for ${files.length} files`);
      return { success: true, output, hasErrors: false };
      
    } catch (error) {
      this.log('debug', `ESLint error: ${error.message}`);
      // ESLint returns non-zero for lint errors, which is expected
      return { 
        success: false, 
        output: error.stdout || error.message,
        hasErrors: true
      };
    }
  }

  async runTypeScript(files, configPath) {
    if (!files.length || !configPath) {
      return { success: true, output: '', hasErrors: false };
    }
    
    try {
      const repoRoot = this.findRepoRoot();
      
      // Check if we're in a Turborepo project
      const turboConfigPath = resolve(repoRoot, 'turbo.json');
      const hasTurbo = existsSync(turboConfigPath);
      
      if (hasTurbo) {
        // For Turborepo with moduleResolution: "bundler", we need a hybrid approach
        // 1. Try to find and use the package-specific typecheck script
        const packageJsonPath = this.findPackageJson(configPath);
        if (packageJsonPath) {
          const packageJson = JSON.parse(readFileSync(packageJsonPath, 'utf8'));
          const packageName = packageJson.name;
          
          if (packageName && packageJson.scripts?.typecheck) {
            const cmd = `pnpm turbo typecheck --filter=${packageName} --force`;
            
            this.log('debug', `Running Turbo TypeScript: ${cmd}`);
            
            const output = execSync(cmd, { 
              encoding: 'utf8',
              cwd: repoRoot,
              stdio: ['ignore', 'pipe', 'pipe']
            });
            
            this.log('info', 'Turbo TypeScript compilation passed');
            return { success: true, output, hasErrors: false };
          }
        }
        
        // 2. If no package typecheck script, use root-level typecheck for the specific package
        if (configPath !== resolve(repoRoot, 'tsconfig.json')) {
          // We're in a package, but try to run typecheck from package directory
          const packageDir = dirname(configPath);
          const packageJson = resolve(packageDir, 'package.json');
          
          if (existsSync(packageJson)) {
            const pkg = JSON.parse(readFileSync(packageJson, 'utf8'));
            
            if (pkg.scripts?.typecheck) {
              const cmd = 'pnpm typecheck';
              
              this.log('debug', `Running package TypeScript: ${cmd} in ${packageDir}`);
              
              const output = execSync(cmd, { 
                encoding: 'utf8',
                cwd: packageDir,
                stdio: ['ignore', 'pipe', 'pipe']
              });
              
              this.log('info', 'Package TypeScript compilation passed');
              return { success: true, output, hasErrors: false };
            }
          }
        }
      }
      
      // Final fallback: Run the file-specific check using tsc with individual files
      // This provides the most granular error detection
      let tscCmd;
      if (existsSync(resolve(repoRoot, 'node_modules', '.bin', 'tsc'))) {
        tscCmd = resolve(repoRoot, 'node_modules', '.bin', 'tsc');
      } else {
        tscCmd = 'tsc';
      }
      
      // Check individual files for maximum error detection
      const fileArgs = files.map(f => `"${f}"`).join(' ');
      const cmd = `${tscCmd} --noEmit --skipLibCheck --strict ${fileArgs}`;
      
      this.log('debug', `Running file-specific TypeScript: ${cmd}`);
      
      const output = execSync(cmd, { 
        encoding: 'utf8',
        cwd: repoRoot,
        stdio: ['ignore', 'pipe', 'pipe']
      });
      
      this.log('info', 'File-specific TypeScript compilation passed');
      return { success: true, output, hasErrors: false };
      
    } catch (error) {
      this.log('debug', `TypeScript error: ${error.message}`);
      return { 
        success: false, 
        output: error.stdout || error.message,
        hasErrors: true
      };
    }
  }

  findPackageJson(filePath) {
    // Find package.json for the given file path
    let currentDir = dirname(resolve(filePath));
    
    while (currentDir !== dirname(currentDir)) {
      const packageJsonPath = resolve(currentDir, 'package.json');
      if (existsSync(packageJsonPath)) {
        return packageJsonPath;
      }
      currentDir = dirname(currentDir);
    }
    
    return null;
  }

  checkStrictRules(files) {
    const violations = [];
    
    for (const file of files) {
      if (!existsSync(file)) continue;
      
      try {
        const content = readFileSync(file, 'utf8');
        const lines = content.split('\n');
        
        lines.forEach((line, index) => {
          const lineNum = index + 1;
          
          // Block `any` type completely
          if (/\bany\b/.test(line) && !line.trim().startsWith('//')) {
            violations.push(`${file}:${lineNum}: BLOCKED - 'any' type is forbidden. Use specific types.`);
          }
          
          // Block `unknown` type (per Florian's requirements)
          if (/\bunknown\b/.test(line) && !line.trim().startsWith('//')) {
            violations.push(`${file}:${lineNum}: BLOCKED - 'unknown' type is forbidden. Use specific types.`);
          }
          
          // Check for `@ts-ignore` or `@ts-expect-error`
          if (/@ts-(ignore|expect-error)/.test(line)) {
            violations.push(`${file}:${lineNum}: WARNING - TypeScript ignore detected. Fix the underlying issue.`);
          }
        });
        
      } catch (error) {
        this.log('debug', `Error reading ${file}: ${error.message}`);
      }
    }
    
    return violations;
  }

  async run() {
    try {
      // Check if TypeScript checking is disabled
      if (process.env.CLAUDE_NO_TS_CHECK === 'true') {
        console.error('[INFO] TypeScript checking disabled via CLAUDE_NO_TS_CHECK=true');
        process.exit(0);
      }
      
      // Parse input from Claude Code hook
      const input = await this.readStdin();
      let hookData;
      
      try {
        hookData = JSON.parse(input);
      } catch (error) {
        this.log('error', 'Invalid JSON input');
        process.exit(2);
      }
      
      const filePath = hookData.tool_input?.file_path;
      
      // Only process TypeScript files
      if (!filePath || !filePath.match(/\.(ts|tsx)$/)) {
        this.log('debug', `Skipping non-TypeScript file: ${filePath}`);
        process.exit(0);
      }
      
      this.log('info', `Processing ${filePath}`);
      
      // Get modified files
      this.modifiedFiles = this.getModifiedFiles();
      if (!this.modifiedFiles.length && filePath) {
        this.modifiedFiles = [filePath];
      }
      
      if (!this.modifiedFiles.length) {
        this.log('debug', 'No TypeScript files to process');
        process.exit(0);
      }
      
      // Find and cache TypeScript config
      const cache = this.loadCache();
      const configPath = this.findTSConfig(filePath);
      
      if (!configPath) {
        this.log('error', 'No TypeScript configuration found');
        process.exit(2);
      }
      
      const configHash = this.getConfigHash(configPath);
      const cacheValid = cache.configPath === configPath && 
                        cache.hashes?.[configPath] === configHash;
      
      if (!cacheValid) {
        this.log('info', 'TypeScript config changed, rebuilding cache');
        cache.configPath = configPath;
        cache.hashes = { [configPath]: configHash };
        this.saveCache(cache);
      }
      
      let hasErrors = false;
      const errors = [];
      
      // 1. Run Prettier (auto-fix) - optional in minimal setup
      this.log('info', 'Running Prettier...');
      const prettierResult = await this.runPrettier(this.modifiedFiles);
      if (!prettierResult.success && !prettierResult.output.includes('command not found')) {
        errors.push(`Prettier failed: ${prettierResult.output}`);
        hasErrors = true;
      } else if (prettierResult.output.includes('command not found')) {
        this.log('info', 'Prettier not found - skipping (install with: npm install -g prettier)');
      }
      
      // 2. Run ESLint (auto-fix + strict rules) - optional in minimal setup
      this.log('info', 'Running ESLint...');
      const eslintResult = await this.runESLint(this.modifiedFiles);
      if (eslintResult.hasErrors && !eslintResult.output.includes('command not found')) {
        errors.push(`ESLint errors: ${eslintResult.output}`);
        hasErrors = true;
      } else if (eslintResult.output.includes('command not found')) {
        this.log('info', 'ESLint not found - skipping (install with: npm install -g eslint)');
      }
      
      // 3. Run TypeScript compilation
      this.log('info', 'Running TypeScript...');
      const tscResult = await this.runTypeScript(this.modifiedFiles, configPath);
      if (tscResult.hasErrors) {
        errors.push(`TypeScript errors: ${tscResult.output}`);
        hasErrors = true;
      }
      
      // 4. Check strict rules (any/unknown)
      this.log('info', 'Checking strict rules...');
      const violations = this.checkStrictRules(this.modifiedFiles);
      if (violations.length > 0) {
        errors.push(`Strict rules violations:\n${violations.join('\n')}`);
        hasErrors = true;
      }
      
      if (hasErrors) {
        this.log('error', 'Quality checks failed');
        console.error('\n=== QUALITY CHECK FAILURES ===');
        errors.forEach(error => console.error(error));
        console.error('=================================\n');
        process.exit(2); // Block Claude until fixed
      } else {
        this.log('ok', 'All quality checks passed');
        process.exit(0);
      }
      
    } catch (error) {
      this.log('error', `Hook execution error: ${error.message}`);
      process.exit(2);
    }
  }

  async readStdin() {
    const chunks = [];
    for await (const chunk of process.stdin) {
      chunks.push(chunk);
    }
    return Buffer.concat(chunks).toString();
  }
}

// Execute hook
const hook = new StrictTypeScriptQualityHook();
hook.run().catch(error => {
  console.error('Fatal error:', error);
  process.exit(2);
});