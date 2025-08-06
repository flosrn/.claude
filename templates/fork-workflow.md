# Fork Workflow Templates

## Safe Fork Commands

### Check Fork Status
```bash
# Verify your fork setup
git remote -v
git branch -vv
gh repo view
```

### Safe Branch Creation and Push
```bash
# Create feature branch
git checkout -b feature/my-feature

# Make your changes, then:
git add .
git commit -m "✨ feat: implement my feature"

# ALWAYS push to origin (your fork)
git push origin feature/my-feature
```

### Safe PR Creation
```bash
# Create PR from your fork to upstream
gh pr create --repo original-owner/repo-name --head flosrn:feature/my-feature --base main
```

### Safe Sync with Upstream
```bash
# Fetch from upstream (read-only)
git fetch upstream

# Switch to main and sync
git checkout main
git merge upstream/main

# Push updates to your fork
git push origin main
```

## Emergency Recovery

### If you accidentally pushed to upstream
```bash
# 1. Don't panic
# 2. Contact the upstream maintainers immediately
# 3. Create a backup of your work
git branch backup-$(date +%s)

# 4. Reset if necessary (only if maintainers agree)
# DON'T RUN THIS WITHOUT PERMISSION
# git push --force-with-lease upstream main^:main
```

### Fix broken remote setup
```bash
# Check current setup
git remote -v

# Fix if origin points to upstream
git remote set-url origin git@github.com:flosrn/repo-name.git

# Ensure upstream is read-only (no pushurl)
git remote set-url upstream git@github.com:original-owner/repo-name.git
git config remote.upstream.pushurl "no_push"
```

## Validation Checklist

Before any Git operation:
- [ ] `git remote -v` shows correct setup
- [ ] origin = flosrn/repo-name (your fork)  
- [ ] upstream = original-owner/repo-name (original)
- [ ] Current branch has local commits
- [ ] Command targets origin, not upstream

## Common Fork Patterns

### Pattern 1: Feature Development
```bash
git checkout -b feature/new-feature
# ... make changes ...
git push origin feature/new-feature
gh pr create --head flosrn:feature/new-feature
```

### Pattern 2: Hotfix
```bash
git checkout -b hotfix/urgent-fix
# ... make minimal fix ...
git push origin hotfix/urgent-fix
gh pr create --head flosrn:hotfix/urgent-fix --base main
```

### Pattern 3: Sync and Continue
```bash
git fetch upstream
git checkout main  
git merge upstream/main
git push origin main
git checkout feature/my-feature
git rebase main  # or git merge main
git push origin feature/my-feature --force-with-lease
```