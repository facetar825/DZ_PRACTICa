from django.db.models.deletion import ProtectedError
from django.test import Client, TestCase
from .models import Director, Genre, Movie


class CinemaTests(TestCase):
    def test_forms_filter_search_sort_and_relationships(self):
        self.client.post("/add/director/", {"name":"Режиссёр", "country":"Россия"})
        self.client.post("/add/genre/", {"name":"Драма"})
        director, genre = Director.objects.get(), Genre.objects.get()
        data = {"title":"Первый", "year":2020, "rating":7, "duration_minutes":100,
                "director":director.pk, "genre":genre.pk}
        self.assertEqual(self.client.post("/add/movie/", data).status_code, 302)
        self.client.post("/add/movie/", dict(data, title="Второй", year=2025, rating=9))
        self.assertEqual(Movie.objects.count(), 2)
        self.assertContains(self.client.get("/?q=Перв"), "Первый (2020)")
        self.assertNotContains(self.client.get("/?q=Перв"), "Второй (2025)")
        page = self.client.get("/?sort=year").content.decode()
        self.assertLess(page.index("Второй"), page.index("Первый"))
        self.assertContains(self.client.get(f"/?genre={genre.pk}"), "Первый")
        self.assertNotContains(self.client.get("/?genre=99999"), "Первый (2020)")
        self.assertEqual(self.client.get("/?genre=" + "9" * 100).status_code, 200)
        self.client.post("/add/movie/", dict(data, rating=11))
        self.assertEqual(Movie.objects.count(), 2)
        self.client.post("/add/genre/", {"name":"Драма"})
        self.assertEqual(Genre.objects.count(), 1)
        with self.assertRaises(ProtectedError):
            genre.delete()
        director.delete()
        self.assertEqual(Movie.objects.count(), 0)
        self.assertEqual(Client(enforce_csrf_checks=True).post("/add/genre/", {"name":"X"}).status_code, 403)
