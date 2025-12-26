# --- Stage 1: Build Frontend ---
FROM node:18-alpine AS frontend-builder

WORKDIR /app/packages/frontend

# COPY packages/frontend/package*.json ./
# RUN npm install
COPY frontend/ .
# RUN npm run build

# --- Stage 2: Build Backend ---
FROM python:3.11-slim-buster AS backend-builder

WORKDIR /app/packages/backend

COPY backend/pyproject.toml backend/poetry.lock ./
RUN pip install poetry
RUN poetry install --no-root --without dev

COPY backend/ ./
# COPY --from=frontend-builder /app/packages/frontend/dist ./static

EXPOSE 8000
WORKDIR /app/packages/backend