import pytest
from sqlmodel import Session, SQLModel, create_engine
from sqlalchemy import event
from sqlalchemy.engine import Engine

from app.models import Message
# from backend.app.db import get_session, DATABASE_URL # No longer directly using these for unit tests

# Use a separate test database connection string for tests
# Connect to localhost:5432 for tests as they run on the host machine
# TEST_DATABASE_URL = "postgresql://user:password@localhost:5432/dogs"

# Use an in-memory SQLite database for fast unit tests
TEST_DATABASE_URL = "sqlite:///:memory:"

# Create the SQLModel engine for tests
test_engine = create_engine(TEST_DATABASE_URL, echo=False)

# Enable foreign key enforcement for SQLite
@event.listens_for(Engine, "connect")
def set_sqlite_pragma(dbapi_connection, connection_record):
    cursor = dbapi_connection.cursor()
    cursor.execute("PRAGMA foreign_keys=ON")
    cursor.close()

@pytest.fixture(name="session")
def session_fixture():
    # SQLModel.metadata.clear() # Removed as it interferes with model registration
    SQLModel.metadata.create_all(test_engine) # Create tables for the test
    with Session(test_engine) as session:
        yield session
    SQLModel.metadata.drop_all(test_engine) # Drop tables after the test


def test_get_session(session: Session):
    """
    Test that we can get a database session.
    """
    assert session is not None


def test_create_and_read_message(session: Session):
    """
    Test creating and reading a Message from the database.
    """
    # Create a new message
    message_to_create = Message(
        role="user",
        type="text",
        content="Hello, world!",
    )

    session.add(message_to_create)
    session.commit()
    session.refresh(message_to_create)

    # Read the message back from the database
    message_from_db = session.get(Message, message_to_create.id)

    assert message_from_db is not None
    assert message_from_db.role == "user"
    assert message_from_db.content == "Hello, world!"

