# Quick Setup Guide - GitHub Actions CI/CD

## What Was Implemented

✅ **GitHub Actions workflow** that automatically:
1. Runs unit tests on every commit (to any branch)
2. Runs unit tests on every pull request
3. Builds Docker image after tests pass (only on main/master)
4. Deploys to Render after successful build (only on main/master)

## File Structure Created

```
.github/
└── workflows/
    ├── ci-cd.yml          # Main workflow configuration
    └── README.md          # Detailed setup instructions
```

## Next Steps (Required for Deployment)

### 1. Get Render Credentials

- **API Key:** Go to https://dashboard.render.com/account/api-keys
- **Service ID:** Check your Render service URL for the ID (format: `srv-XXXXX`)

### 2. Add GitHub Secrets

Navigate to: **Your Repository → Settings → Secrets and variables → Actions**

Add two secrets:
- Name: `RENDER_API_KEY` → Value: Your Render API key
- Name: `RENDER_SERVICE_ID` → Value: Your Render service ID (e.g., `srv-abc123`)

### 3. Test the Workflow

**Option A - Merge this PR:**
```bash
# After merging to main/master, the workflow will automatically:
# 1. Run tests
# 2. Build Docker image
# 3. Deploy to Render (if secrets are configured)
```

**Option B - Test on this branch first:**
```bash
# Push any commit to see the test job run:
git commit --allow-empty -m "Trigger test workflow"
git push
```

## How to Monitor

1. Go to **Actions** tab in GitHub
2. Click on the latest workflow run
3. View logs for each job (test, build-and-deploy)

## What Happens Now

### On Every Commit/PR:
- ✅ Unit tests run automatically
- ✅ Status shows on commit/PR (✓ or ✗)

### On Push to Main/Master:
- ✅ Tests run first
- ✅ If tests pass → Docker image builds
- ✅ If build succeeds → Deployment to Render triggers
- ❌ If secrets not configured → Warning message (no deployment)

## Workflow Behavior

| Event | Tests Run? | Build Docker? | Deploy to Render? |
|-------|-----------|---------------|-------------------|
| Push to feature branch | ✅ Yes | ❌ No | ❌ No |
| Pull request | ✅ Yes | ❌ No | ❌ No |
| Push to main/master | ✅ Yes | ✅ Yes (if tests pass) | ✅ Yes (if secrets set) |

## Troubleshooting

**Tests failing?**
- Check the Actions tab for detailed logs
- Tests use the same command as `./test_backend_unit.sh`

**Deployment not working?**
- Verify secrets are set correctly
- Check Render service ID format (should be `srv-XXXXX`)
- Review workflow logs in Actions tab

**Need to skip deployment temporarily?**
- Remove the GitHub secrets temporarily
- The workflow will show a warning but won't fail

## Additional Resources

- Full documentation: `.github/workflows/README.md`
- Render API docs: https://render.com/docs/api
- GitHub Actions docs: https://docs.github.com/actions
