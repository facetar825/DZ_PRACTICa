import tempfile
import unittest
from pathlib import Path
from app import Message, Visit, create_app, db


class GuestbookTest(unittest.TestCase):
    def test_persistence_escaping_visits_and_validation(self):
        with tempfile.TemporaryDirectory() as directory:
            uri = "sqlite:///" + (Path(directory) / "test.db").as_posix()
            app = create_app({"TESTING":True, "SQLALCHEMY_DATABASE_URI":uri})
            client = app.test_client()
            self.assertEqual(client.get("/health").text, "OK")
            client.get("/")
            self.assertEqual(client.post("/add", data={"author":"", "text":"X"}).status_code, 400)
            self.assertEqual(client.post("/add", data={"author":"Тест", "text":"<script>alert(1)</script>"}).status_code, 303)
            page = client.get("/").text
            self.assertIn("&lt;script&gt;", page)
            self.assertNotIn("<script>", page)
            with app.app_context():
                self.assertEqual(db.session.scalar(db.select(db.func.count(Visit.id))), 2)
                db.session.remove()
                db.engine.dispose()
            other = create_app({"TESTING":True, "SQLALCHEMY_DATABASE_URI":uri})
            self.assertIn("Тест", other.test_client().get("/").text)
            with other.app_context():
                self.assertEqual(db.session.scalar(db.select(db.func.count(Message.id))), 1)
                db.session.remove()
                db.engine.dispose()


if __name__ == "__main__":
    unittest.main()
