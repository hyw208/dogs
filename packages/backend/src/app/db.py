from typing import Generator
from sqlmodel import Session, create_engine, SQLModel
import os
# Import all models to ensure they are registered with SQLModel
from app.models import *


# Database connection URLs for different environments
DATABASE_URLS = {
    "local": "postgresql://user:password@localhost:5432/dogs", # For local development/testing on host
    "docker": "postgresql://user:password@db:5432/dogs", # For when the app runs inside Docker
    # Add other environments (dev, test, prod) here as needed
}

# Determine the current environment from an environment variable, default to "docker"
CURRENT_ENV = os.getenv("APP_ENV", "docker")
DATABASE_URL = DATABASE_URLS.get(CURRENT_ENV, DATABASE_URLS["docker"])

# Create the SQLModel engine
engine = create_engine(DATABASE_URL, echo=True)

def create_db_and_tables():
    """
    Create database tables based on SQLModel metadata.
    This is for initial setup or testing without migrations.
    """
    SQLModel.metadata.create_all(engine)

def get_session() -> Generator[Session, None, None]:
    """
    Dependency to get a database session.
    """
    with Session(engine) as session:
        yield session

