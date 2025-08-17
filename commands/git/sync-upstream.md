# Sync Upstream (Makerkit)

**Intelligent upstream sync following Makerkit's recommended procedure**
*Automates the complete Makerkit codebase update workflow*

## Task Workflow
Following Makerkit's official procedure for Next.js Supabase Turbo Starter Kit:
1. **Preparation**: Stash/commit current changes
2. **Create Update Branch**: Branch with date suffix  
3. **Fetch & Merge**: Pull upstream changes safely
4. **Conflict Resolution**: Handle lock files and database types
5. **Health Verification**: Type check and lint validation
6. **Finalization**: Commit, push, and create PR

## Implementation Steps

### Step 0: Date Acquisition
1. **Get Current Date**: Execute `date +%Y-%m-%d` to obtain today's date
2. **Store Date Variable**: Use result for branch naming throughout process

### Step 1: Preparation & Safety
1. **Check Working Directory**: Ensure clean state or stash changes
2. **Verify Remotes**: Confirm upstream remote exists
3. **Current Branch Check**: Note current branch for restoration
4. **Backup Option**: Offer to stash uncommitted changes

### Step 2: Create Update Branch  
1. **Switch to Main**: `git checkout main`
2. **Pull Latest**: `git pull origin main` (sync your fork first)
3. **Create Branch**: `git checkout -b update-codebase-YYYY-MM-DD` (using date from Step 0)
4. **Confirm Creation**: Verify branch creation success

### Step 3: Fetch Upstream Changes
1. **Fetch Upstream**: `git fetch upstream`
2. **Merge Strategy**: `git pull upstream main` (merge, not rebase)
3. **Handle Prompts**: Auto-select merge when prompted
4. **Status Check**: Verify merge completion

### Step 4: Dependency Update
1. **Update Dependencies**: `pnpm i` (or npm/yarn based on project)
2. **Lock File Check**: Verify dependency resolution
3. **Installation Verification**: Ensure successful install

### Step 5: Conflict Resolution (Automated)

#### A) Lock File Conflicts (`pnpm-lock.yaml`)
- **Detection**: Check if lock file has conflicts
- **Resolution**: Accept upstream version, then `pnpm i`
- **Verification**: Ensure dependencies resolve correctly

#### B) Database Types Conflicts (`database.types.ts`)
- **Detection**: Check for database types conflicts
- **Reset Database**: `npm run supabase:web:reset`
- **Regenerate Types**: `npm run supabase:web:typegen`
- **Verification**: Confirm types generation success

### Step 6: Project Health Verification
1. **Type Checking**: `pnpm run typecheck`
2. **Linting**: `pnpm run lint`
3. **Build Test** (optional): `pnpm run build`
4. **Error Handling**: Report any issues found

### Step 7: Finalization
1. **Stage Changes**: `git add .`
2. **Auto-Commit**: Generate conventional commit message
3. **Push Branch**: `git push origin update-codebase-YYYY-MM-DD`
4. **Create PR**: Optional PR creation to merge into main

## Makerkit-Specific Handling

### Package Manager Detection
- **Auto-detect**: Check for `pnpm-lock.yaml`, `package-lock.json`, `yarn.lock`
- **Priority**: pnpm → npm → yarn
- **Commands**: Use appropriate package manager for all operations

### Supabase Integration
- **Database Reset**: Only if `database.types.ts` conflicts detected
- **Type Generation**: Automatic regeneration after reset
- **Verification**: Ensure Supabase services remain functional

### Common Conflict Patterns
- **Lock files**: Always regenerate after accepting changes
- **Config files**: Merge carefully, preserving customizations
- **Database schemas**: Reset and regenerate when needed
- **Environment files**: Preserve local configurations

## Safety Features
- **Backup Current State**: Stash or commit before starting
- **Rollback Capability**: Ability to abort and restore
- **Verification Steps**: Health checks at each stage
- **Error Recovery**: Clear guidance for manual resolution

## Smart Commit Generation
Auto-generate commit message based on upstream changes:
```
🔄 chore(upstream): sync with Makerkit upstream YYYY-MM-DD

- Updated dependencies via upstream merge
- Resolved lock file conflicts  
- Regenerated database types
- Verified project health (typecheck + lint)

Source: Makerkit Next.js Supabase Turbo Starter
```

## Integration Features
- **CCNotify**: Progress notifications at each step
- **Observability**: Log complete sync operation
- **Flashback**: Save sync context for troubleshooting
- **Quality Gates**: Respect existing CI/CD requirements

## Error Handling & Recovery
- **Merge Conflicts**: Guided resolution with Makerkit patterns
- **Build Failures**: Step-by-step debugging assistance
- **Dependency Issues**: Automatic lock file regeneration
- **Database Errors**: Supabase reset and type regeneration

## Command Arguments
- `$ARGUMENTS` - Optional date override: `/sync-upstream 2024-01-15`
- **Auto-date**: Execute `date +%Y-%m-%d` to get current date if no argument provided
- **Branch naming**: `update-codebase-YYYY-MM-DD` format

## Date Handling Logic
1. **If arguments provided**: Use provided date (validate format YYYY-MM-DD)
2. **If no arguments**: Execute `date +%Y-%m-%d` to obtain current system date
3. **Branch creation**: Use resolved date for `update-codebase-{date}` branch name

## Verification Checklist
After sync completion:
- [ ] Dependencies installed successfully
- [ ] Type checking passes
- [ ] Linting passes  
- [ ] Database types current
- [ ] Supabase connection working
- [ ] Build succeeds (if tested)

## Usage Examples
```bash
/sync-upstream                    # Auto-date: update-codebase-2024-01-15
/sync-upstream 2024-01-20        # Custom date: update-codebase-2024-01-20
```

## Warning Prompts
Before execution, confirm:
- "This will merge upstream changes into a new branch"
- "Uncommitted changes will be stashed"
- "Database may be reset if conflicts detected"
- "Continue with Makerkit upstream sync? (y/N)"

Usage: `/sync-upstream [YYYY-MM-DD]`

**Perfect for**: Regular Makerkit boilerplate updates, security patches, and feature syncs.