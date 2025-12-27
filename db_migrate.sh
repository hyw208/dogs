#!/usr/bin/env bash
# This script runs Alembic commands using Poetry for the backend package.

set -euo pipefail

# Parse arguments
COMMAND=""
MESSAGE=""
ALEMBIC_ENVIRONMENT="" # Corresponds to APP_ENV in db.py and ALEMBIC_ENV in env.py
ALEMBIC_COMMAND_ARGS=()

# Process arguments
while (( "$#" )); do
  case "$1" in
    --env)
      if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
        ALEMBIC_ENVIRONMENT="$2"
        shift 2
      else
        echo "Error: Argument for --env is missing" >&2
        exit 1
      fi
      ;;
    -m|--message)
      if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
        MESSAGE="$2"
        shift 2
      else
        echo "Error: Argument for --message is missing" >&2
        exit 1
      fi
      ;;
    *)
      # preserve positional arguments
      if [ -z "$COMMAND" ]; then
        COMMAND="$1"
      else
        ALEMBIC_COMMAND_ARGS+=("$1")
      fi
      shift
      ;;
  esac
done

# Set default environment if not specified
if [ -z "$ALEMBIC_ENVIRONMENT" ]; then
    ALEMBIC_ENVIRONMENT="local" # Default to 'local' for host execution
fi

# Set environment variables for env.py to use
export ALEMBIC_ENV="$ALEMBIC_ENVIRONMENT"

# Ensure we are in the packages/backend directory for Alembic to find its config
# and the models correctly.
cd packages/backend

echo "Running Alembic command: $COMMAND for environment: $ALEMBIC_ENVIRONMENT"

# --- Debugging ---
echo "ALEMBIC_ENV: $ALEMBIC_ENV"
# --- End Debugging ---


if [ "$COMMAND" == "revision" ]; then
  if [ -z "$MESSAGE" ]; then
    echo "Error: A message is required for the 'revision' command."
    echo "Usage: ./db_migrate.sh revision \"Your migration message\" [--env <env_name>]"
    exit 1
  fi
  PYTHONPATH=./src poetry run alembic revision --autogenerate -m "$MESSAGE" --head=base "${ALEMBIC_COMMAND_ARGS[@]}"
elif [ "$COMMAND" == "init" ]; then
  # Remove alembic directory if it exists to ensure a clean init
  rm -rf alembic
  
  # Initialize Alembic env in the 'alembic' directory relative to packages/backend
  # This creates alembic.ini and env.py in their pristine state
  PYTHONPATH=./src poetry run alembic init alembic
  
  # Set alembic.ini's sqlalchemy.url to the Docker hostname as base,
  # This is safe as it's a config file and not Python source code.
  ALEMBIC_INI="alembic.ini"
  ENV_PY="alembic/env.py" # Path to env.py for later modification by 'replace' tool
  sed -i '' "s|sqlalchemy.url = driver://user:pass@localhost/dbname|sqlalchemy.url = postgresql://user:password@db:5432/dogs|" "$ALEMBIC_INI"
  sed -i '' "s|script_location = alembic|script_location = alembic|" "$ALEMBIC_INI" # Ensure this line is present, may already be
  
else
  # For other alembic commands (e.g., upgrade, downgrade, history, current)
  PYTHONPATH=./src poetry run alembic "$COMMAND" "${ALEMBIC_COMMAND_ARGS[@]}"
fi
