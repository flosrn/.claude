---
title: 'Makerkit Upstream Update'
read_only: true
type: 'command'
description: "Automated Makerkit boilerplate upstream update workflow with branch management, conflict resolution, and PR creation"
allowed-tools:
  [
    "Bash(git checkout:*)",
    "Bash(git branch:*)",
    "Bash(git stash:*)",
    "Bash(git pull:*)",
    "Bash(git push:*)",
    "Bash(git commit:*)",
    "Bash(git status:*)",
    "Bash(git remote:*)",
    "Bash(pnpm:*)",
    "Bash(npm run:*)",
    "Bash(gh pr:*)",
    "Read(*)",
    "Edit(*)"
  ]
---

# Makerkit Upstream Update

Automated workflow for updating Makerkit boilerplate projects with upstream changes, including branch management, dependency updates, conflict resolution, and PR creation.

## Target Projects

- **L'AS de la route** (`/Users/flo/Code/nextjs-lasdelaroute`)
- **Gapila** (`/Users/flo/Code/nextjs-gapila`)

Both projects are based on the Makerkit Next.js Supabase Turbo boilerplate.

## Process

1. **Pre-Update Validation**:

   - Verify we're in a Makerkit-based project directory
   - Check for uncommitted changes in working directory
   - Verify upstream remote is properly configured
   - Confirm project has `pnpm-lock.yaml` and Supabase configuration
   - Display current branch status and last upstream sync date

2. **Backup and Stash Management**:

   - If uncommitted changes exist, offer options:
     - Stash changes with descriptive message
     - Commit changes with provided message
     - Abort update process
   - Create backup reference point before proceeding

3. **Branch Creation**:

   - Generate date-based branch name: `update-makerkit-upstream-YYYY-MM-DD`
   - Create and checkout new branch from main/master
   - Verify branch creation successful
   - Display active branch confirmation

4. **Upstream Sync Process**:

   - Fetch latest upstream changes: `git pull upstream main`
   - Choose merge strategy (default to merge over rebase for first prompt)
   - Monitor for merge conflicts during pull operation
   - Log upstream changes pulled (commit count and summary)

5. **Dependency Management**:

   - Update dependencies: `pnpm i`
   - Handle `pnpm-lock.yaml` conflicts if they occur:
     - Accept one version of lock file changes
     - Regenerate lock file with `pnpm i`
     - Verify dependency resolution successful

6. **Supabase Configuration Handling**:

   - Check for `database.types.ts` conflicts
   - If conflicts detected in database types:
     - Reset Supabase database: `npm run supabase:web:reset`
     - Regenerate types: `npm run supabase:web:typegen`
     - Verify type generation successful
   - Handle other Supabase-related configuration conflicts

7. **Project Health Verification**:

   - Run TypeScript type checking: `pnpm run typecheck`
   - Run ESLint validation: `pnpm run lint`
   - Fix linting issues automatically where possible
   - Report any unresolvable type errors or lint issues
   - Ensure all automated quality gates pass

8. **Conflict Resolution**:

   - If merge conflicts remain after automated resolution:
     - Display conflict files and affected lines
     - Guide through manual conflict resolution
     - Validate resolution maintains project functionality
     - Stage resolved conflicts
   - Verify no unresolved conflicts remain

9. **Update Documentation**:

   - Check for changes in README.md, CHANGELOG.md, or documentation
   - Review and validate documentation updates
   - Ensure project-specific customizations are preserved
   - Update version references if applicable

10. **Commit and Push**:

    - Stage all updated files
    - Create descriptive commit message: `chore: update Makerkit boilerplate to latest upstream (YYYY-MM-DD)`
    - Include summary of major changes in commit body
    - Commit all changes
    - Push branch to origin: `git push origin update-makerkit-upstream-YYYY-MM-DD`

11. **Pull Request Creation**:

    - Create PR using GitHub CLI: `gh pr create`
    - Use template PR title: `🔄 Update Makerkit boilerplate - [Current Date]`
    - Generate comprehensive PR body including:
      - Summary of upstream changes pulled
      - Dependencies updated
      - Configuration changes made
      - Manual conflicts resolved (if any)
      - Testing checklist for reviewer
    - Assign appropriate reviewers if configured
    - Add relevant labels (enhancement, dependencies, upstream-update)

12. **Post-Update Validation**:

    - Verify PR creation successful
    - Display PR URL for review
    - Run final quality checks on pushed branch
    - Provide next steps for testing and merging
    - Suggest timeline for merging based on change complexity

## Special Considerations

### Makerkit-Specific Handling

- **Package.json scripts**: Preserve custom scripts added to the project
- **Environment variables**: Maintain project-specific `.env` configurations
- **Database schema**: Handle Supabase schema conflicts carefully
- **Custom components**: Ensure project-specific components aren't overwritten
- **Configuration files**: Preserve project-specific Tailwind, Next.js configs

### Conflict Resolution Priority

1. **Accept upstream**: For core Makerkit functionality improvements
2. **Keep local**: For project-specific customizations and business logic  
3. **Merge both**: For complementary changes that don't conflict
4. **Manual review**: For complex conflicts affecting critical functionality

### Safety Measures

- **Never force push** to main/master branches
- **Never push to upstream** remote (read-only)
- **Backup verification**: Ensure backup references exist before major operations
- **Rollback capability**: Provide clear rollback instructions if update fails
- **Team notification**: Inform team members of update PR creation

## Error Recovery

### Common Issues and Solutions

- **Upstream remote missing**: Configure with `git remote add upstream https://github.com/makerkit/next-supabase-saas-kit-turbo.git`
- **Merge conflicts**: Guide through conflict resolution workflow
- **Type errors after update**: Run type generation and fix imports
- **Lock file issues**: Delete node_modules and pnpm-lock.yaml, run `pnpm i`
- **Supabase connection errors**: Verify environment variables and reset if needed

### Rollback Process

1. Switch back to main branch
2. Delete update branch if needed
3. Restore stashed changes if applicable
4. Verify project returns to pre-update state

## Success Criteria

- ✅ All upstream changes successfully merged
- ✅ Dependencies updated and lockfile consistent  
- ✅ TypeScript compilation passes
- ✅ Linting validation passes
- ✅ Supabase configuration valid
- ✅ Project builds successfully
- ✅ PR created with comprehensive description
- ✅ No merge conflicts remaining
- ✅ Team notified of update availability

## Notes

- Updates should be performed regularly (weekly or bi-weekly) to avoid large conflict sets
- Test major updates in development environment before merging to production
- Consider feature flags for significant upstream changes that might affect user experience
- Document any manual customizations that consistently conflict with updates
- Coordinate with team on timing of updates to avoid disrupting active development

## Attribution Rules

- **NEVER add Claude Code attribution to update commits**
- **NEVER include Co-Authored-By: Claude in upstream merge commits**
- All Git operations must appear as authored solely by the human developer
- Maintain clean commit history that reflects natural development workflow