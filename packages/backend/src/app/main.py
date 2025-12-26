from fastapi import FastAPI, Depends, Query
from fastapi.staticfiles import StaticFiles
from sqlmodel import Session, select
import os
from typing import List, Optional

from app.db import get_session
from app.models.message import Message


app = FastAPI()

@app.get("/api/health")
def health_check():
    return {"status": "ok"}

@app.get("/api/messages", response_model=List[Message])
def get_messages(
    *,
    session: Session = Depends(get_session),
    page_number: int = 1,
    records_per_page: int = Query(default=10, le=100)
):
    """
    Retrieve a paginated list of messages from the database.
    """
    offset = (page_number - 1) * records_per_page
    messages = session.exec(select(Message).offset(offset).limit(records_per_page)).all()
    return messages

# Mount static files (React build) - MUST BE AFTER ALL API ROUTES
static_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../static"))
app.mount("/", StaticFiles(directory=static_dir, html=True), name="static")
