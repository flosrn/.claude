---
name: update
description: Full Makerkit codebase migration from upstream with conflict resolution and reporting
allowed-tools: Bash, Read, Edit, Task
argument-hint: [--dry-run]
---

# Makerkit Update Command

Execute a full codebase update from upstream Makerkit repository.

## Workflow

1. **Pre-checks**
   - Verify clean working directory
   - Check upstream remote is configured
   - Detect project (gapila/lasdelaroute)

2. **Delegate to makerkit-updater agent**
   - Creates update branch
   - Fetches and merges upstream
   - Resolves conflicts (using package-conflict-resolver for package.json)
   - Updates dependencies
   - **Fixes circular dependencies (MANDATORY)**
   - Runs health checks
   - **Validates with `pnpm dev` (MANDATORY)**

3. **Generate report**
   - Delegates to update-reporter agent
   - Saves to `docs/reports/makerkit-update-YYYY-MM-DD.md`

4. **Create PR** (only if pnpm dev succeeds)
   - Commits all changes
   - Pushes branch
   - Creates GitHub PR

## Usage

```
/makerkit:update
```

With dry-run (check without applying):
```
/makerkit:update --dry-run
```

## Arguments

- `--dry-run`: Only check for upstream changes without applying them

## Execution

If `--dry-run` is specified:
```bash
git fetch upstream
git log --oneline HEAD..upstream/main | head -20
```

Otherwise, delegate to the `makerkit-updater` agent:

```
Use the makerkit-updater agent to perform a full codebase update from upstream
```

## Expected Output

```
## Makerkit Update

**Project**: gapila
**Status**: Update complete

### Changes
- Merged X commits from upstream
- Resolved Y conflicts
- Updated Z packages
- Fixed circular dependencies: YES

### Health
- Circular Dependencies: FIXED ✅
- TypeScript: PASS ✅
- Lint: PASS ✅
- pnpm dev: PASS ✅

### Next Steps
1. Review PR at [URL]
2. Test locally
3. Merge when ready

### Report
See docs/reports/makerkit-update-YYYY-MM-DD.md
```

## Important

The update will NOT create a PR if:
- Circular dependencies are not fixed
- `pnpm dev` fails to start

These are hard requirements, not warnings.
