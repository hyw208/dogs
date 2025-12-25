# Code Style and Enforcement Guide

This document outlines the plan for enforcing code style for JavaScript, TypeScript, and Python, as well as guidelines for managing database schema and data changes.

## JavaScript/TypeScript (ESLint & Prettier)

1.  **Initialize `package.json`**: Create a `package.json` file to manage project dependencies and scripts by running the command `npm init -y`.
2.  **Install Dependencies**: Install the necessary Node.js packages as development dependencies. This will include:
    *   `eslint`: The core ESLint library.
    *   `prettier`: The core Prettier library for code formatting.
    *   `@typescript-eslint/parser`: To allow ESLint to parse TypeScript code.
    *   `@typescript-eslint/eslint-plugin`: Provides TypeScript-specific linting rules.
    *   `eslint-config-prettier`: Disables ESLint rules that would conflict with Prettier.
    *   `eslint-plugin-prettier`: Runs Prettier as an ESLint rule.
3.  **Create `.eslintrc.js`**: Create a configuration file for ESLint that will:
    *   Set up the TypeScript parser.
    *   Enable recommended rules from ESLint and the TypeScript plugin.
    *   Integrate Prettier for formatting.
4.  **Create `.prettierrc`**: Create a configuration file for Prettier to define specific formatting rules (e.g., indentation, trailing commas).
5.  **Add Scripts to `package.json`**: Add `lint` and `format` scripts to your `package.json` file for easily running the tools from your command line.

## Python (Poetry, Black & Flake8)

1.  **Initialize Poetry**: Use `poetry init` to create a `pyproject.toml` file in the `backend` directory to manage Python dependencies and project settings.
2.  **Add Dependencies**: Use `poetry add` to add dependencies. Main dependencies like `fastapi` and `sqlmodel` will be added directly, while development dependencies like `black`, `flake8`, and `pytest` will be added to the `dev` group (`poetry add --group dev <package>`).
3.  **Create `.flake8` configuration file**: Create a configuration file for Flake8 to set rules, such as line length, and ensure it works well with Black.
4.  **Virtual Environment**: Poetry will automatically manage a virtual environment to isolate the project's dependencies. Commands should be run through `poetry run` (e.g., `poetry run pytest`).

## Database Schema Changes Style Guide

All database schema changes must be managed through a migration tool to ensure consistency and reversibility. Based on the project's use of Python and SQLModel, we will use **Alembic** for this purpose.

*   **Migration Generation**: For any change to a `SQLModel` schema, a new Alembic migration script must be generated. This is done using the `poetry run alembic revision --autogenerate` command.
*   **Migration Application**: Migrations are applied using `poetry run alembic upgrade head` to bring the database to the latest version.
*   **Status Checks**: Before committing any schema changes, developers should run `poetry run alembic check` or a similar command to ensure the database schema is in sync with the models.
*   **Reversibility**: All migrations should be reversible. Avoid destructive operations in migration scripts where possible. If a data migration is needed, it should be handled carefully and tested.

## Database Data Changes Style Guide

Changes to data (e.g., seeding, default data, test data) should be handled separately from schema migrations.

*   **Dedicated Scripts/Functions**: Create dedicated functions or scripts for data changes. These should be clearly named to indicate their purpose (e.g., `seed_initial_data()`, `reset_test_data()`).
*   **Idempotency**: Data change scripts should be idempotent where possible. This means they can be run multiple times without causing errors or creating duplicate data.
*   **Source Control**: All scripts for data changes must be committed to the repository.
*   **Separation from Schema**: Do not mix data manipulation with schema migration scripts unless the data change is essential for the schema change to succeed (e.g., populating a new non-nullable column).
