# Dogs App

A full-stack application built with FastAPI (backend) and a modern frontend.

## Project Structure

```
dogs/
├── packages/
│   ├── backend/          # FastAPI backend
│   ├── frontend/         # Frontend application
│   └── Dockerfile        # Multi-stage Docker build
├── .github/
│   └── workflows/        # GitHub Actions CI/CD workflows
├── test_backend_unit.sh  # Local unit test script
├── build_image.sh        # Local Docker build script
└── docker-compose.yml    # Local development setup
```

## Quick Start

### Local Development

1. **Run unit tests:**
   ```bash
   ./test_backend_unit.sh
   ```

2. **Build Docker image:**
   ```bash
   ./build_image.sh
   ```

3. **Run with Docker Compose:**
   ```bash
   docker-compose up
   ```

## CI/CD with GitHub Actions

This repository is configured with automated CI/CD using GitHub Actions:

### Automated Workflows

- **On every commit/PR:** Unit tests run automatically
- **On push to main/master:** After tests pass, Docker image is built and deployed to Render

### Setup Instructions

To enable automatic deployment to Render:

1. **Get your Render API credentials:**
   - API Key: https://dashboard.render.com/account/api-keys
   - Service ID: Found in your service URL (`srv-XXXXX`)

2. **Add GitHub secrets:**
   - Go to: Repository → Settings → Secrets and variables → Actions
   - Add `RENDER_API_KEY` with your Render API key
   - Add `RENDER_SERVICE_ID` with your Render service ID

3. **Push to main/master branch:**
   - Tests will run automatically
   - On success, deployment to Render is triggered

For detailed setup instructions, see [.github/workflows/README.md](.github/workflows/README.md)

## Development

### Backend Tests

```bash
cd packages/backend
PYTHONPATH=./src poetry run pytest
```

### Technologies Used

- **Backend:** FastAPI, SQLModel, PostgreSQL, Alembic
- **Frontend:** Node.js
- **Deployment:** Docker, Render
- **CI/CD:** GitHub Actions
