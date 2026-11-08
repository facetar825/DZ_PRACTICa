import os
from datetime import datetime
from zoneinfo import ZoneInfo

from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()
TIME_ZONE = ZoneInfo(os.environ.get("TODO_TIME_ZONE", "Asia/Irkutsk"))


def local_now():
    return datetime.now(TIME_ZONE).replace(tzinfo=None)


class Task(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text)
    deadline = db.Column(db.DateTime, nullable=False)
    priority = db.Column(db.String(10), nullable=False, default="medium")
    is_done = db.Column(db.Boolean, nullable=False, default=False)
    created_at = db.Column(db.DateTime, nullable=False, default=local_now)
