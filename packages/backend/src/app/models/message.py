from datetime import datetime, UTC
from typing import Optional

from sqlmodel import Field, SQLModel
from sqlalchemy import Column
from sqlalchemy.types import JSON

class Message(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: Optional[str] = Field(default=None, index=True)
    session_id: Optional[str] = Field(default=None, index=True)
    run_id: Optional[str] = Field(default=None, index=True)
    agent_id: Optional[str] = Field(default=None, index=True)
    parent_id: Optional[str] = Field(default=None, index=True)
    role: str
    type: str
    content: str
    created_at: datetime = Field(default_factory=lambda: datetime.now(UTC))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(UTC))
    feedback: Optional[dict] = Field(default=None, sa_column=Column(JSON))
    rating: Optional[int] = None
    tool_code: Optional[str] = None
    tool_code_result: Optional[str] = None
    is_deleted: bool = Field(default=False)
