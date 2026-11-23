from contextlib import closing
import os
import re
import sqlite3
import tempfile
import unittest
from pathlib import Path

from app import User, create_app, db


class AuthTest(unittest.TestCase):
    def test_registration_login_logout_and_two_databases(self):
        with tempfile.TemporaryDirectory() as directory:
            os.environ["AUTH_DATA_DIR"] = directory
            app = create_app({"TESTING": True})
            client = app.test_client()
            self.assertEqual(client.get("/profile").status_code, 302)

            def token(path):
                html = client.get(path).text
                return re.search(r'name="csrf_token"[^>]*value="([^"]+)"', html)[1]

            self.assertEqual(client.post("/register", data={}).status_code, 400)
            form = dict(username="student", email="student@example.com", password="LongPassword9",
                        csrf_token=token("/register"))
            self.assertEqual(client.post("/register", data=form).status_code, 303)
            old_cookie = client.get_cookie("session").value
            self.assertIn("student@example.com", client.get("/profile").text)
            self.assertEqual(client.get("/login").status_code, 302)
            with app.app_context():
                user = db.session.scalar(db.select(User))
                self.assertNotEqual(user.password_hash, form["password"])
            with closing(sqlite3.connect(Path(directory) / "users.db")) as connection:
                self.assertEqual(connection.execute("SELECT count(*) FROM users").fetchone()[0], 1)
                self.assertIsNone(connection.execute("SELECT name FROM sqlite_master WHERE name='sessions'").fetchone())
            with closing(sqlite3.connect(Path(directory) / "sessions.db")) as connection:
                self.assertEqual(connection.execute("SELECT count(*) FROM sessions").fetchone()[0], 1)
                self.assertIsNone(connection.execute("SELECT name FROM sqlite_master WHERE name='users'").fetchone())
            self.assertEqual(client.post("/logout").status_code, 400)
            self.assertEqual(client.post("/logout", data={"csrf_token":token("/profile")}).status_code, 303)
            attacker = app.test_client()
            attacker.set_cookie("session", old_cookie)
            self.assertEqual(attacker.get("/profile").status_code, 302)
            self.assertEqual(client.get("/profile").status_code, 302)
            login = dict(username="student", password="wrong", csrf_token=token("/login"))
            self.assertIn("Неверное", client.post("/login", data=login).text)
            login["password"] = "LongPassword9"
            self.assertEqual(client.post("/login", data=login).status_code, 303)
            self.assertNotEqual(client.get_cookie("session").value, old_cookie)
            duplicate = dict(form, csrf_token=token("/register"))
            self.assertIn("заняты", client.post("/register", data=duplicate).text)
            with app.app_context():
                db.session.remove()
                for engine in db.engines.values():
                    engine.dispose()


if __name__ == "__main__":
    unittest.main()
