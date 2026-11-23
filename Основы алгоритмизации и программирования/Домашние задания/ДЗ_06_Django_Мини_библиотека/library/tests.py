from django.test import Client, TestCase
from .models import Author, Book


class LibraryTest(TestCase):
    def test_create_list_validation_and_cascade(self):
        author = Author.objects.create(name="Автор")
        self.assertContains(self.client.get("/books/"), "Книг пока нет")
        self.assertEqual(self.client.get("/books/new/").status_code, 200)
        data = {"title":"Книга", "author":author.pk, "year":2026}
        self.assertRedirects(self.client.post("/books/new/", data), "/books/")
        page = self.client.get("/books/")
        for text in ["Книга", "Автор", "2026"]:
            self.assertContains(page, text)
        self.client.post("/books/new/", dict(data, title=""))
        self.client.post("/books/new/", dict(data, year="abc"))
        self.client.post("/books/new/", dict(data, author=999))
        self.assertEqual(Book.objects.count(), 1)
        with self.assertNumQueries(1):
            for book in Book.objects.select_related("author"):
                str(book.author.name)
        self.assertEqual(Client(enforce_csrf_checks=True).post("/books/new/", data).status_code, 403)
        author.delete()
        self.assertEqual(Book.objects.count(), 0)
