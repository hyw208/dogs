############################################################
# Stage 1: Frontend build (Node)
############################################################
FROM node:20-alpine AS frontend-builder

WORKDIR /app/packages/frontend

# Install dependencies first to leverage Docker layer caching
COPY frontend/package*.json ./
# Install bash to run helper script, then install deps via script (ci with fallback)
RUN apk add --no-cache bash
COPY --chmod=0755 frontend/frontend.sh ./
RUN ./frontend.sh ci-install

# Copy the rest of the frontend source and build
COPY frontend/ .
RUN ./frontend.sh build

############################################################
# Stage 2: Backend runtime (Python)
############################################################
FROM python:3.11-slim AS backend

WORKDIR /app/packages/backend

# Install backend dependencies using Poetry
COPY backend/pyproject.toml backend/poetry.lock ./
RUN pip install --no-cache-dir poetry \
 && poetry config virtualenvs.create false \
 && poetry install --no-root --without dev

# Copy backend source
COPY backend/ ./

# Copy built frontend assets into backend static directory
COPY --from=frontend-builder /app/packages/frontend/dist ./static

EXPOSE 8000

# Default command (adjust if your app entry differs)
# Example using Uvicorn to serve FastAPI app defined in app/main.py as `app`
CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]