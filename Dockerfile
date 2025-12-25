# --- Stage 1: Build Frontend ---
FROM node:18-alpine AS frontend-builder

WORKDIR /app/frontend

COPY frontend/package*.json ./
RUN npm install
COPY frontend/ .
RUN npm run build

# --- Stage 2: Build Backend ---
FROM python:3.10-slim-buster AS backend-builder

WORKDIR /app

RUN pip install poetry
COPY backend/poetry.lock backend/pyproject.toml ./
RUN poetry install --no-root --no-dev
COPY backend/ ./backend/
COPY --from=frontend-builder /app/frontend/dist ./backend/static
EXPOSE 8000
WORKDIR /app/backend
CMD ["poetry", "run", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]