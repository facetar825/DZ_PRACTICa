import os
import secrets
from datetime import datetime, timedelta, timezone
from pathlib import Path

from flask import Flask, flash, redirect, render_template, session, url_for
from flask_session import Session
from flask_sqlalchemy import SQLAlchemy
from flask_wtf import CSRFProtect, FlaskForm
from sqlalchemy.exc import IntegrityError
from werkzeug.security import check_password_hash, generate_password_hash
from wtforms import PasswordField, StringField
from wtforms.validators import Email, InputRequired, Length, Regexp

db = SQLAlchemy()


class User(db.Model):
    __bind_key__ = "users"
    __tablename__ = "users"
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(40), unique=True, nullable=False)
    email = db.Column(db.String(254), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))


class RegisterForm(FlaskForm):
    username = StringField("Имя пользователя", filters=[lambda v: (v or "").strip().lower()],
                           validators=[Length(min=3, max=40), Regexp(r"^[\w.-]+$", message="Буквы, цифры, точка, дефис и подчёркивание.")])
    email = StringField("Email", filters=[lambda v: (v or "").strip().lower()],
                        validators=[InputRequired(), Email(), Length(max=254)])
    password = PasswordField("Пароль", validators=[InputRequired(), Length(min=8, max=128)])


class LoginForm(FlaskForm):
    username = StringField("Имя пользователя", filters=[lambda v: (v or "").strip().lower()],
                           validators=[InputRequired(), Length(max=40)])
    password = PasswordField("Пароль", validators=[InputRequired(), Length(max=128)])


def create_app(config=None):
    app = Flask(__name__)
    folder = Path(os.environ.get("AUTH_DATA_DIR", Path(__file__).parent / "instance")).resolve()
    folder.mkdir(parents=True, exist_ok=True)
    secret = os.environ.get("AUTH_SECRET_KEY")
    if not secret:
        key_file = folder / "secret.key"
        try:
            with key_file.open("x", encoding="ascii") as stream:
                stream.write(secrets.token_hex(32))
        except FileExistsError:
            pass
        secret = key_file.read_text(encoding="ascii")
    app.config.update(
        SECRET_KEY=secret,
        SQLALCHEMY_DATABASE_URI="sqlite:///" + (folder / "sessions.db").as_posix(),
        SQLALCHEMY_BINDS={"users": "sqlite:///" + (folder / "users.db").as_posix()},
        SESSION_TYPE="sqlalchemy", SESSION_SQLALCHEMY_TABLE="sessions",
        SESSION_PERMANENT=True, PERMANENT_SESSION_LIFETIME=timedelta(days=7),
        SESSION_COOKIE_HTTPONLY=True, SESSION_COOKIE_SAMESITE="Lax",
    )
    app.config.update(config or {})
    db.init_app(app)
    app.config["SESSION_SQLALCHEMY"] = db
    Session(app)
    CSRFProtect(app)
    with app.app_context():
        db.create_all()

    def sign_in(user):
        session.clear()
        session["user_id"] = user.id
        session.permanent = True
        app.session_interface.regenerate(session)

    @app.get("/")
    def index():
        return redirect(url_for("profile" if session.get("user_id") else "login"))

    @app.route("/register", methods=["GET", "POST"])
    def register():
        form = RegisterForm()
        if form.validate_on_submit():
            user = User(username=form.username.data, email=form.email.data,
                        password_hash=generate_password_hash(form.password.data))
            db.session.add(user)
            try:
                db.session.commit()
            except IntegrityError:
                db.session.rollback()
                flash("Имя пользователя или email уже заняты.")
            else:
                sign_in(user)
                return redirect(url_for("profile"), code=303)
        return render_template("register.html", form=form)

    @app.route("/login", methods=["GET", "POST"])
    def login():
        if session.get("user_id"):
            return redirect(url_for("profile"))
        form = LoginForm()
        if form.validate_on_submit():
            user = db.session.scalar(db.select(User).where(User.username == form.username.data))
            if user and check_password_hash(user.password_hash, form.password.data):
                sign_in(user)
                return redirect(url_for("profile"), code=303)
            flash("Неверное имя пользователя или пароль.")
        return render_template("login.html", form=form)

    @app.get("/profile")
    def profile():
        user = db.session.get(User, session.get("user_id")) if session.get("user_id") else None
        if user is None:
            return redirect(url_for("login"))
        return render_template("profile.html", user=user, form=FlaskForm())

    @app.post("/logout")
    def logout():
        session.clear()
        return redirect(url_for("login"), code=303)

    return app


if __name__ == "__main__":
    create_app().run(port=5002)
