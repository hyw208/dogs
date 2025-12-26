# GitHub Actions CI/CD Setup

This repository uses GitHub Actions to automatically run tests and deploy to Render.

## Workflow Overview

The CI/CD pipeline consists of two main jobs:

### 1. Test Job (runs on every push and PR)
- Runs on every commit to any branch
- Sets up Python 3.11 and Poetry
- Installs backend dependencies
- Runs unit tests using pytest

### 2. Build and Deploy Job (runs only on main/master branch)
- Only runs after tests pass
- Only runs on pushes to `main` or `master` branch (not on PRs)
- Builds the Docker image
- Triggers deployment to Render

## Setup Instructions

### Prerequisites
1. A Render account with a service configured
2. GitHub repository with admin access

### Required GitHub Secrets

To enable deployment to Render, you need to add the following secrets to your GitHub repository:

1. **RENDER_API_KEY**: Your Render API key
   - Go to [Render Dashboard](https://dashboard.render.com/account/api-keys)
   - Create a new API key
   - Copy the key

2. **RENDER_SERVICE_ID**: Your Render service ID
   - Go to your service in Render Dashboard
   - The service ID is in the URL: `https://dashboard.render.com/web/srv-XXXXX` (the `srv-XXXXX` part)

### Adding Secrets to GitHub

1. Go to your GitHub repository
2. Click on **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add both secrets:
   - Name: `RENDER_API_KEY`, Value: your Render API key
   - Name: `RENDER_SERVICE_ID`, Value: your Render service ID

## How It Works

### On Every Commit/PR
- GitHub Actions automatically runs unit tests
- You'll see a check mark (✓) or X (✗) on your commit/PR indicating test status
- PRs cannot be merged if tests fail (recommended to enable this in branch protection rules)

### On Push to Main/Master
- After tests pass, the workflow builds the Docker image
- Then triggers a deployment to Render using the Render API
- Render will pull the latest code and deploy your application

## Manual Workflow Trigger

You can also manually trigger the workflow from the GitHub Actions tab in your repository.

## Viewing Workflow Runs

1. Go to the **Actions** tab in your GitHub repository
2. Click on a workflow run to see details
3. View logs for each job to debug any issues

## Local Testing

Before pushing, you can run tests locally using the existing scripts:

```bash
# Run unit tests
./test_backend_unit.sh

# Build Docker image
./build_image.sh
```

## Troubleshooting

### Tests failing in CI but passing locally
- Ensure all dependencies are in `pyproject.toml`
- Check Python version (CI uses Python 3.11)

### Deployment not triggering
- Verify secrets are set correctly in GitHub repository settings
- Check that you're pushing to `main` or `master` branch
- Review workflow logs in the Actions tab

### Render deployment failing
- Verify your Render service is configured correctly
- Check that your Render service has access to the GitHub repository
- Review Render deployment logs

## Additional Configuration

### Branch Protection Rules (Recommended)
1. Go to **Settings** → **Branches**
2. Add a branch protection rule for `main` or `master`
3. Enable **Require status checks to pass before merging**
4. Select the **Run Unit Tests** check

This ensures no code is merged without passing tests.
