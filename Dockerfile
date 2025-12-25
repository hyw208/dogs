# --- Stage 1: Build Frontend ---
FROM node:18-alpine AS frontend-builder

WORKDIR /app/packages/frontend

COPY packages/frontend/package*.json ./
RUN npm install
COPY packages/frontend/ .
RUN npm run build

# --- Stage 2: Build Backend ---
FROM python:3.10-slim-buster AS backend-builder

WORKDIR /app/packages/backend

RUN pip install poetry
COPY packages/backend/pyproject.toml packages/backend/poetry.lock ./
RUN poetry install --no-root --no-dev
COPY packages/backend/ ./
COPY --from=frontend-builder /app/packages/frontend/dist ./static
EXPOSE 8000
WORKDIR /app/packages/backend
CMD ["poetry", "run", "uvicorn", "src.app.main:app", "--host", "0.0.0.0", "--port", "8000"]