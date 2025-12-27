# Project Architecture

This document outlines the high-level architecture, folder structure, and deployment strategy for the application, specifically focusing on how the React frontend and FastAPI backend interact and are deployed.

## Folder Structure

The project will adopt a monorepo-like structure, separating the frontend and backend into distinct directories.

```
/
├── packages/
│   ├── backend/
│   │   ├── app/                 # Core Python application logic (models, db setup)
│   │   │   ├── __init__.py
│   │   │   ├── models.py
│   │   │   └── db.py
│   │   ├── tests/               # Python unit and integration tests
│   │   ├── alembic/             # Alembic environment directory
│   │   │   └── versions/        # Alembic migration scripts
│   │   ├── alembic.ini
│   │   └── pyproject.toml
│   └── frontend/
│       ├── src/                 # React source code, components, and co-located unit tests (*.test.tsx)
│       ├── cypress/             # Cypress e2e tests
│       │   └── e2e/             # E2e test specs
│       ├── public/              # Static assets
│       ├── package.json         # Frontend dependencies and scripts
│       ├── vite.config.ts       # Vite configuration
│       ├── jest.config.ts       # Jest configuration
│       ├── cypress.config.ts    # Cypress configuration
│       └── frontend.sh          # Helper script for frontend tasks (install, build, test, e2e, clean)
├── docker-compose.yml       # Defines Docker services (e.g., PostgreSQL)
├── Dockerfile               # Multi-stage Docker build for the application
├── db.sh                    # Helper script for database management
├── code-style-enforcement.md# Document for code style enforcement setup
├── architecture.md          # This document
├── conductor/               # Conductor project management files
│   └── ...
└── ... (other root-level files like .gitignore, README.md)
```

**Testing Conventions:**
- **Frontend unit tests** (Jest/React Testing Library): Co-located with source files (e.g., `App.test.tsx` next to `App.tsx` in `src/`). This follows standard React conventions, makes tests easier to find and maintain, and works seamlessly with Jest's auto-discovery.
- **Frontend e2e tests** (Cypress): Organized in `cypress/e2e/` directory.
- **Backend tests** (pytest): Organized in `tests/` directory separate from source code.

## Local Development Environment

This project uses Docker for managing services like the PostgreSQL database. The `db.sh` script relies on `docker-compose`.

### macOS Users
For macOS users, **Colima** is the recommended tool for running the Docker environment. Please ensure Colima is started (`colima start`) before running any Docker commands or using the `./db.sh` script.

## Environment Variables

The application's behavior can be configured using environment variables.

*   **`APP_ENV`**: This variable controls the application's environment context, primarily for selecting the correct database connection URL.
    *   **Purpose**: Allows the application to connect to different databases (e.g., local development, Docker container, staging, production) without code changes.
    *   **Values**:
        *   `docker`: (Default) Connects to the PostgreSQL service named 'db' within the Docker network.
        *   `local`: Connects to 'localhost' for local development/testing directly on the host machine.
        *   (Other values can be added for staging, production, etc., with corresponding URLs in `backend/src/app/db.py`).
    *   **Usage**: Set this environment variable before starting the application or running migrations. Example: `APP_ENV=local ./db_migrate.sh upgrade head`

## Database Migration Strategy

This section outlines the agreed-upon strategy for managing Alembic migrations across different environments, addressing the challenges of connecting to a Dockerized database from the host system and allowing environment-specific configurations.

### Problem Statement

When running Alembic commands (e.g., `revision`, `upgrade`) from the host machine (outside the Docker container), Alembic needs to connect to the PostgreSQL database.
1.  The `docker-compose.yml` configures the database service with the hostname `db` (resolvable within the Docker network).
2.  When running on the host, `db` is not resolvable; `localhost` must be used.
3.  We need a flexible way to manage different database URLs for various environments (local development, Docker-internal, staging, production, etc.) without modifying core configuration files (`alembic.ini`) for each run.
4.  Crucially, we agree to **avoid using `sed` or similar tools to dynamically modify Python source code files (`env.py`)** within our scripts, to prevent syntax errors and maintain code integrity.

### Agreed Solution: Environment Variables and Centralized URL Map

The chosen solution leverages environment variables and a centralized map of database URLs to provide dynamic and flexible environment management.

#### 1. Centralized Database URL Map (`packages/backend/src/app/db.py`)

*   A Python dictionary named `DATABASE_URLS` will be maintained in `packages/backend/src/app/db.py`. This dictionary will map environment names (e.g., `"docker"`, `"local"`, `"staging"`, `"production"`) to their respective database connection strings.
*   The `DATABASE_URL` used by the application's engine will be dynamically selected from this map based on the `APP_ENV` environment variable, defaulting to `"docker"` if `APP_ENV` is not set.

#### 2. Dynamic `env.py` Configuration (`packages/backend/alembic/env.py`)

*   `packages/backend/alembic/env.py` will be modified (a one-time, direct Python code modification using the `replace` tool) to prioritize reading the database connection URL from the `ALEMBIC_DATABASE_URL` environment variable.
*   If `ALEMBIC_DATABASE_URL` is set, `env.py` will use this URL to establish the connection for migrations.
*   If `ALEMBIC_DATABASE_URL` is *not* set, `env.py` will fall back to using the `sqlalchemy.url` defined in `alembic.ini` (which defaults to the Docker-internal `db` hostname).
*   `env.py` will also import `os` and `create_engine` from `sqlalchemy` to support this dynamic behavior.

#### 3. `db_migrate.sh` Script for Environment Orchestration

*   The `db_migrate.sh` script will be responsible for orchestrating Alembic commands and setting the necessary environment variables.
*   It will accept an optional `--env <environment_name>` argument.
*   Based on this `--env` argument (or defaulting to `"local"` if not provided):
    *   It will set the `APP_ENV` environment variable (primarily for the application's `db.py` when it runs).
    *   It will set the `ALEMBIC_DATABASE_URL` environment variable to the appropriate URL for the specified environment (e.g., `postgresql://user:password@localhost:5432/dogs` for `local`).
*   **Crucially, `db_migrate.sh` will contain no `sed` commands for modifying `alembic.ini` or `env.py` for dynamic host resolution.** `alembic.ini` will remain configured with the `db` hostname, which is then overridden by `ALEMBIC_DATABASE_URL` via `env.py` when `db_migrate.sh` is executed on the host.

### Execution Flow for Alembic Commands (e.g., `revision`, `upgrade`)

1.  User runs `./db_migrate.sh <command> [--env <env_name>]`.
2.  `db_migrate.sh` sets `APP_ENV` and `ALEMBIC_DATABASE_URL` based on the `--env` argument.
3.  `db_migrate.sh` executes `poetry run alembic <command>`.
4.  Alembic invokes `env.py`.
5.  `env.py` detects `ALEMBIC_DATABASE_URL` (set by `db_migrate.sh`), and uses it to connect to the database (e.g., `localhost:5432` for `local` env).


## Frontend Build and Backend Serving Strategy

The application will be deployed as a single Docker container where the FastAPI backend is responsible for serving both the API endpoints and the static files of the React frontend.

1.  **Build React Application**: The React application (`frontend/`) will be built using Vite (`npm run build`). This process compiles all React/TypeScript code into optimized static HTML, CSS, and JavaScript files, typically outputting them to a `frontend/dist/` directory.
2.  **Copy Built Assets**: These static files from `frontend/dist/` will then be copied into a `backend/static/` directory.
3.  **FastAPI Serves Static Files**: The FastAPI application will be configured to serve these static files from the `backend/static/` directory. Any HTTP request that does not match an API endpoint (e.g., `/api/messages`) will default to serving the `index.html` from `backend/static/`, thereby loading the React single-page application.

## Dockerfile Multi-Stage Build

To automate the build and deployment of this integrated application, we will use a multi-stage `Dockerfile`:

```dockerfile
# --- Stage 1: Build Frontend ---
FROM node:18-alpine AS frontend-builder

WORKDIR /app/frontend

# Copy package.json and package-lock.json to install dependencies
COPY frontend/package*.json ./
RUN npm install

# Copy the rest of the frontend source code
COPY frontend/ .

# Build the React application
RUN npm run build

# --- Stage 2: Build Backend ---
FROM python:3.10-slim-buster AS backend-builder

WORKDIR /app

# Install Poetry
RUN pip install poetry

# Copy Poetry config and lock file
COPY backend/poetry.lock backend/pyproject.toml ./

# Install dependencies, excluding dev dependencies
RUN poetry install --no-root --no-dev

# Copy the backend source code
COPY backend/ ./backend/

# Copy the built frontend assets from the frontend-builder stage
COPY --from=frontend-builder /app/frontend/dist ./backend/static

# Expose the port FastAPI will run on
EXPOSE 8000

# Set the working directory for the final command
WORKDIR /app/backend

# Command to run the FastAPI application
# (This will be adjusted based on the actual entry point, e.g., using Uvicorn)
CMD ["poetry", "run", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

This multi-stage Dockerfile ensures that:
*   The frontend is built efficiently in isolation.
*   Only the necessary build artifacts (static files) are copied into the final backend image, keeping the image size minimal.
*   The final image is self-contained, serving both the API and the React application via FastAPI.

## Helper Scripts Organization

**Root-level scripts** (`db.sh`, `db_migrate.sh`, `deploy.sh`, etc.):
*   Orchestration/ops for the whole system (docker, database migrations, service startup).
*   Placed at the root to be reachable from CI pipelines and for easy access without needing to navigate into package directories.

**Package-level scripts** (`packages/frontend/frontend.sh`):
*   Scoped to a single package (e.g., UI build, test, dev server).
*   Kept inside the package directory to avoid accidental root-level runs and maintain clear boundaries.
*   Example: `frontend.sh` is a helper for frontend-only tasks (install, build, test, e2e, clean).

## Frontend Build and Backend Serving Strategy

The application will be deployed as a single Docker container where the FastAPI backend is responsible for serving both the API endpoints and the static files of the React frontend.

1.  **Build React Application**: The React application (`frontend/`) will be built using Vite (`npm run build`). This process compiles all React/TypeScript code into optimized static HTML, CSS, and JavaScript files, typically outputting them to a `frontend/dist/` directory.
2.  **Copy Built Assets**: These static files from `frontend/dist/` will then be copied into a `backend/static/` directory.
3.  **FastAPI Serves Static Files**: The FastAPI application will be configured to serve these static files from the `backend/static/` directory. Any HTTP request that does not match an API endpoint (e.g., `/api/messages`) will default to serving the `index.html` from `backend/static/`, thereby loading the React single-page application.

## Dockerfile Multi-Stage Build

To automate the build and deployment of this integrated application, we will use a multi-stage `Dockerfile`:

```dockerfile
# --- Stage 1: Build Frontend ---
FROM node:18-alpine AS frontend-builder

WORKDIR /app/frontend

# Copy package.json and package-lock.json to install dependencies
COPY frontend/package*.json ./
RUN npm install

# Copy the rest of the frontend source code
COPY frontend/ .

# Build the React application
RUN npm run build

# --- Stage 2: Build Backend ---
FROM python:3.10-slim-buster AS backend-builder

WORKDIR /app

# Install Poetry
RUN pip install poetry

# Copy Poetry config and lock file
COPY backend/poetry.lock backend/pyproject.toml ./

# Install dependencies, excluding dev dependencies
RUN poetry install --no-root --no-dev

# Copy the backend source code
COPY backend/ ./backend/

# Copy the built frontend assets from the frontend-builder stage
COPY --from=frontend-builder /app/frontend/dist ./backend/static

# Expose the port FastAPI will run on
EXPOSE 8000

# Set the working directory for the final command
WORKDIR /app/backend

# Command to run the FastAPI application
# (This will be adjusted based on the actual entry point, e.g., using Uvicorn)
CMD ["poetry", "run", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

This multi-stage Dockerfile ensures that:
*   The frontend is built efficiently in isolation.
*   Only the necessary build artifacts (static files) are copied into the final backend image, keeping the image size minimal.
*   The final image is self-contained, serving both the API and the React application via FastAPI.
