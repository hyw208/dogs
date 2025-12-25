from logging.config import fileConfig
import os

from sqlalchemy import engine_from_config
from sqlalchemy import pool
from sqlalchemy import create_engine # Added to resolve NameError

from alembic import context
from sqlmodel import SQLModel # Added for target_metadata
from src.app.db import DATABASE_URLS # Added for environment-specific URLs
# Removed 'from src.app.models import *' to prevent re-registration errors.
# Models will be loaded indirectly via 'from src.app.db import engine'

# this is the Alembic Config object, which provides
# access to the values within the .ini file in use.
config = context.config

# Interpret the config file for Python logging.
# This line sets up loggers basically.
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# add your model's MetaData object here
# for 'autogenerate' support
# from myapp import mymodel
# target_metadata = mymodel.Base.metadata
target_metadata = SQLModel.metadata # Set to SQLModel.metadata

# other values from the config, defined by the needs of env.py,
# can be acquired:
# my_important_option = config.get_main_option("my_important_option")
# ... etc.


def run_migrations_offline() -> None:
    """Run migrations in 'offline' mode.

    This configures the context with just a URL
    and not an Engine, though an Engine is acceptable
    here as well.  By skipping the Engine creation
    we don't even need a DBAPI to be available.

    Calls to context.execute() here emit the given string to the
    script output.

    """
    # Prefer Alembic database URL from environment variable
    alembic_env = os.getenv("ALEMBIC_ENV", "docker") # Default to docker for offline
    url = DATABASE_URLS.get(alembic_env, config.get_main_option("sqlalchemy.url"))
    print(f"ALEMBIC_ENV (offline mode): {alembic_env}")
    print(f"Using URL (offline mode): {url}")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )

    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    """Run migrations in 'online' mode.

    In this scenario we need to create an Engine
    and associate a connection with the context.

    """
    alembic_env = os.getenv("ALEMBIC_ENV", "docker") # Default to docker
    db_url = DATABASE_URLS.get(alembic_env)

    print(f"ALEMBIC_ENV (online mode): {alembic_env}") # Debugging

    if db_url:
        print(f"Using URL from DATABASE_URLS for environment '{alembic_env}': {db_url}") # Debugging
        connectable = create_engine(db_url)
    else:
        db_url_from_ini = config.get_main_option("sqlalchemy.url")
        print(f"ALEMBIC_ENV not found in DATABASE_URLS. Using URL from alembic.ini: {db_url_from_ini}") # Debugging
        connectable = engine_from_config(
            config.get_section(config.config_ini_section, {}),
            prefix="sqlalchemy.",
            poolclass=pool.NullPool,
        )

    with connectable.connect() as connection:
        context.configure(
            connection=connection, target_metadata=target_metadata
        )

        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
