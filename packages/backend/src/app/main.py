import os
from pathlib import Path
from typing import List

from fastapi import FastAPI, Depends, Query
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from sqlmodel import Session, select

from app.db import get_session
from app.models.message import Message

app = FastAPI()

# Static directory setup
STATIC_DIR = Path(__file__).parent.parent.parent / "static"
INDEX_HTML = STATIC_DIR / "index.html"


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
    """Retrieve a paginated list of messages from the database."""
    offset = (page_number - 1) * records_per_page
    messages = session.exec(select(Message).offset(offset).limit(records_per_page)).all()
    return messages


# Mount static assets (must be after API routes)
app.mount("/assets", StaticFiles(directory=str(STATIC_DIR / "assets")), name="assets")


@app.get("/", response_class=HTMLResponse)
async def serve_root():
    """Serve the React app's index.html."""
    return HTMLResponse(content=INDEX_HTML.read_text(encoding="utf-8"))


@app.get("/{path:path}", response_class=HTMLResponse)
async def serve_spa(path: str):
    """Fallback route for client-side routing."""
    return HTMLResponse(content=INDEX_HTML.read_text(encoding="utf-8"))
