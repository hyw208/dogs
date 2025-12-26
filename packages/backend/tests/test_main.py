import pytest
from fastapi.testclient import TestClient
from sqlmodel import Session, select
# SQLModel, create_engine, event, Engine, and session fixture moved to conftest.py

from app.main import app
from app.db import get_session
from app.models.message import Message

# The 'session' fixture and 'test_db_engine' are now provided by packages/backend/tests/conftest.py

@pytest.fixture(name="client")
def client_fixture(session):
    """
    Fixture to provide a TestClient with an overridden database session.
    """
    def get_session_override():
        yield session
    app.dependency_overrides[get_session] = get_session_override
    client = TestClient(app)
    yield client
    app.dependency_overrides.clear() # Clear overrides after the test

def test_health_check(client: TestClient):
    """
    Test the /api/health endpoint.
    """
    response = client.get("/api/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}

def test_get_messages_empty(client: TestClient):
    """
    Test retrieving messages when the database is empty.
    """
    response = client.get("/api/messages")
    assert response.status_code == 200
    assert response.json() == []

def test_get_messages_pagination(client: TestClient, session: Session): # 'session' here is from conftest.py
    """
    Test retrieving messages with pagination.
    """
    # Create 20 messages for testing pagination using the session from conftest.py
    for i in range(20):
        message = Message(
            role="user",
            type="text",
            content=f"Test message {i}",
        )
        session.add(message)
    session.commit()

    # Test default pagination (page_number=1, records_per_page=10)
    response = client.get("/api/messages")
    assert response.status_code == 200
    messages = response.json()
    assert len(messages) == 10
    assert messages[0]["content"] == "Test message 0"
    assert messages[9]["content"] == "Test message 9"

    # Test page 2, 5 records per page
    response = client.get("/api/messages?page_number=2&records_per_page=5")
    assert response.status_code == 200
    messages = response.json()
    assert len(messages) == 5
    assert messages[0]["content"] == "Test message 5"
    assert messages[4]["content"] == "Test message 9"

    # Test last page with remaining records
    response = client.get("/api/messages?page_number=4&records_per_page=5")
    assert response.status_code == 200
    messages = response.json()
    assert len(messages) == 5
    assert messages[0]["content"] == "Test message 15"
    assert messages[4]["content"] == "Test message 19"
