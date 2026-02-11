# Makerkit Upgrade Checklist

## Pre-Upgrade

- [ ] Commit or stash all local changes
- [ ] Create update branch: `git checkout -b update-codebase-YYYY-MM-DD`
- [ ] Verify upstream remote: `git remote -v | grep upstream`
- [ ] If missing: `git remote add upstream https://github.com/makerkit/next-supabase-turbo.git`

## Upgrade Process

- [ ] Fetch upstream: `git fetch upstream`
- [ ] Pull with merge: `git pull upstream main --no-rebase`
- [ ] Handle merge conflicts (see conflict resolution)

## Conflict Resolution

### Package.json Conflicts
- [ ] Use `resolve-package-conflicts` agent for each conflicted package.json
- [ ] Run `pnpm i` after all resolved

### Lock File (pnpm-lock.yaml)
- [ ] Accept either version: `git checkout --theirs pnpm-lock.yaml`
- [ ] Regenerate: `pnpm i`

### Database Types (database.types.ts)
- [ ] Reset database: `pnpm supabase:web:reset`
- [ ] Regenerate types: `pnpm supabase:web:typegen`

### Config/Code Conflicts
- [ ] Review each conflict manually
- [ ] Preserve local customizations
- [ ] Test affected functionality

## Post-Upgrade

- [ ] Install dependencies: `pnpm i`
- [ ] Run typecheck: `pnpm typecheck`
- [ ] Run lint: `pnpm lint:fix`
- [ ] Run syncpack: `pnpm syncpack:fix`
- [ ] Test critical paths

## Finalize

- [ ] Commit changes
- [ ] Push branch
- [ ] Create PR for review
- [ ] Test in staging before merge
