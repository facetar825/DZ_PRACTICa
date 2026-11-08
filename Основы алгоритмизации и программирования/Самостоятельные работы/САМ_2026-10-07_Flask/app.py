import os
import secrets
from datetime import timedelta
from pathlib import Path

from flask import Flask, redirect, render_template, url_for
from flask_wtf import FlaskForm

from forms import PRIORITIES, TaskForm
from models import Task, db, local_now

GROUPS = {
    "overdue": "Просроченные",
    "today": "Сегодня",
    "week": "На этой неделе",
    "later": "Позже",
    "done": "Выполненные",
}


def task_group(task, now):
    if task.is_done:
        return "done"
    if task.deadline < now:
        return "overdue"
    today = now.date()
    if task.deadline.date() == today:
        return "today"
    sunday = today + timedelta(days=6 - today.weekday())
    return "week" if task.deadline.date() <= sunday else "later"


def create_app(config=None):
    app = Flask(__name__)
    app.config.from_mapping(
        SECRET_KEY=os.environ.get("TODO_SECRET_KEY") or secrets.token_hex(32),
        SQLALCHEMY_DATABASE_URI="sqlite:///tasks.sqlite3",
    )
    app.config.update(config or {})
    Path(app.instance_path).mkdir(parents=True, exist_ok=True)
    db.init_app(app)
    with app.app_context():
        db.create_all()

    @app.get("/")
    def index():
        tasks = db.session.scalars(db.select(Task).order_by(Task.deadline, Task.id)).all()
        now = local_now()
        grouped = {key: [] for key in GROUPS}
        for task in tasks:
            grouped[task_group(task, now)].append(task)
        return render_template(
            "index.html", groups=GROUPS, grouped=grouped, total=len(tasks),
            actions=FlaskForm(), priorities=dict(PRIORITIES),
        )

    @app.route("/tasks/new", methods=["GET", "POST"])
    @app.route("/tasks/<int:task_id>/edit", methods=["GET", "POST"])
    def edit(task_id=None):
        task = db.get_or_404(Task, task_id) if task_id is not None else Task()
        form = TaskForm(obj=task)
        if form.validate_on_submit():
            form.populate_obj(task)
            db.session.add(task)
            db.session.commit()
            return redirect(url_for("index"), code=303)
        return render_template("edit.html", form=form, is_new=task_id is None)

    @app.post("/tasks/<int:task_id>/status/<int:done>")
    def set_status(task_id, done):
        if done not in (0, 1):
            return "", 404
        if not FlaskForm().validate_on_submit():
            return "Недействительный запрос", 400
        task = db.get_or_404(Task, task_id)
        task.is_done = bool(done)
        db.session.commit()
        return redirect(url_for("index"), code=303)

    @app.post("/tasks/<int:task_id>/delete")
    def delete(task_id):
        if not FlaskForm().validate_on_submit():
            return "Недействительный запрос", 400
        db.session.delete(db.get_or_404(Task, task_id))
        db.session.commit()
        return redirect(url_for("index"), code=303)

    return app


if __name__ == "__main__":
    create_app().run(port=5000)
