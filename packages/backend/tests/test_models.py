import pytest
from sqlmodel import SQLModel, Session, create_engine, select
from app.models import Message
from datetime import datetime, UTC

def test_message_model_fields():
    now = datetime.now(UTC)
    msg = Message(
        user_id="user1",
        session_id="sess1",
        run_id="run1",
        agent_id="agent1",
        parent_id="parent1",
        role="user",
        type="text",
        content="hello",
        created_at=now,
        updated_at=now,
        feedback={"score": 5},
        rating=5,
        tool_code="code",
        tool_code_result="result",
        is_deleted=False
    )
    assert msg.user_id == "user1"
    assert msg.content == "hello"
    assert msg.feedback == {"score": 5}
    assert msg.rating == 5
    assert not msg.is_deleted

def test_message_model_defaults():
    msg = Message(role="system", type="text", content="hi")
    assert msg.id is None
    assert msg.created_at is not None
    assert msg.updated_at is not None
    assert msg.is_deleted is False

def test_message_model_table():
    engine = create_engine("sqlite:///:memory:")
    SQLModel.metadata.create_all(engine)
    with Session(engine) as session:
        msg = Message(role="user", type="text", content="test")
        session.add(msg)
        session.commit()
        result = session.exec(select(Message).where(Message.content == "test")).first()
        assert result is not None
        assert result.content == "test"
