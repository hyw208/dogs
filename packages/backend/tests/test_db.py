import pytest
from sqlmodel import Session, SQLModel
# SQLModel, create_engine and related db setup moved to conftest.py

from app.models import Message
# from backend.app.db import get_session, DATABASE_URL # No longer directly using these for unit tests

# The 'session' fixture is now provided by packages/backend/tests/conftest.py

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

