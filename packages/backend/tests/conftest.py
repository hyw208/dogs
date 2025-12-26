import pytest
from sqlmodel import Session, SQLModel, create_engine
from sqlalchemy import event
from sqlalchemy.engine import Engine

# Import all models to ensure they are registered with SQLModel.metadata
from app.models import * 

# Use an in-memory SQLite database for fast unit tests
TEST_DATABASE_URL = "sqlite:///:memory:"

@pytest.fixture(name="test_db_engine", scope="function")
def test_db_engine_fixture():
    """
    Provides a test database engine for each test function, ensuring isolation.
    Establishes a persistent connection to the in-memory SQLite database,
    creates tables, and drops them afterwards.
    """
    current_test_engine = create_engine(TEST_DATABASE_URL, echo=False, connect_args={"check_same_thread": False})
    
    # Establish a connection and keep it open for the duration of the test
    # This is crucial for in-memory SQLite to persist the database
    connection = current_test_engine.connect()

    # Enable foreign key enforcement for SQLite for this connection
    @event.listens_for(current_test_engine, "connect") 
    def set_sqlite_pragma(dbapi_connection, connection_record):
        cursor = dbapi_connection.cursor()
        cursor.execute("PRAGMA foreign_keys=ON")
        cursor.close()

    SQLModel.metadata.create_all(connection) # Create tables on this connection
    yield current_test_engine # Yield the engine
    SQLModel.metadata.drop_all(connection) # Drop tables
    connection.close() # Close the persistent connection

@pytest.fixture(name="session", scope="function")
def session_fixture(test_db_engine):
    with test_db_engine.connect() as connection:
        with Session(bind=connection) as session:
            yield session