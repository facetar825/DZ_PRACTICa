import os
from datetime import datetime, timezone
from pathlib import Path

from flask import Flask, redirect, render_template_string, request, url_for
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()


class Visit(db.Model):
    __tablename__ = "visits"
    id = db.Column(db.Integer, primary_key=True)
    ts = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))


class Message(db.Model):
    __tablename__ = "messages"
    id = db.Column(db.Integer, primary_key=True)
    author = db.Column(db.String(50), nullable=False)
    text = db.Column(db.Text, nullable=False)
    ts = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))


TEMPLATE = """<!doctype html><html lang="ru"><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Гостевая книга</title>
<style>body{max-width:45rem;margin:2rem auto;padding:1rem;font:18px/1.5 system-ui;background:#eff4fa;color:#18304d}input,button{font:inherit;padding:.5rem;max-width:100%;box-sizing:border-box}label{display:block}li{overflow-wrap:anywhere}</style>
<h1>Гостевая книга</h1><p>Счётчик посещений: <b>{{ count }}</b></p>
<form method="post" action="{{ url_for('add') }}">
<label>Имя <input name="author" maxlength="50" required></label>
<label>Сообщение <input name="text" maxlength="2000" required></label><button>Отправить</button></form>
<ul>{% for m in messages %}<li><b>{{ m.author }}</b> ({{ m.ts.strftime('%Y-%m-%d %H:%M') }}): {{ m.text }}</li>{% else %}<li>Пока сообщений нет</li>{% endfor %}</ul></html>"""


def create_app(config=None):
    app = Flask(__name__)
    path = Path(os.environ.get("DB_PATH", Path(__file__).parent / "data.db")).resolve()
    path.parent.mkdir(parents=True, exist_ok=True)
    app.config.update(SQLALCHEMY_DATABASE_URI="sqlite:///" + path.as_posix())
    app.config.update(config or {})
    db.init_app(app)
    with app.app_context():
        db.create_all()

    @app.get("/")
    def index():
        db.session.add(Visit())
        db.session.commit()
        return render_template_string(TEMPLATE,
            count=db.session.scalar(db.select(db.func.count(Visit.id))),
            messages=db.session.scalars(db.select(Message).order_by(Message.ts.desc(), Message.id.desc())).all())

    @app.post("/add")
    def add():
        author = request.form.get("author", "").strip()
        text = request.form.get("text", "").strip()
        if not 1 <= len(author) <= 50 or not 1 <= len(text) <= 2000:
            return "Имя: 1–50 символов, сообщение: 1–2000 символов.", 400
        db.session.add(Message(author=author, text=text))
        db.session.commit()
        return redirect(url_for("index"), code=303)

    @app.get("/health")
    def health():
        return "OK", 200

    return app


if __name__ == "__main__":
    create_app().run(host="0.0.0.0", port=5000)
