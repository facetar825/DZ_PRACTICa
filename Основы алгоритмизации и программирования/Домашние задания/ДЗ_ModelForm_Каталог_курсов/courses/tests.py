from django.test import Client, TestCase
from .forms import CourseForm
from .models import Course


class CourseTests(TestCase):
    data = {"title": "Основы Python", "description": "Работа с переменными и функциями", "seats": 10}

    def test_seats_validation_and_boundaries(self):
        for seats in [1, 30]:
            form = CourseForm(dict(self.data, seats=seats))
            self.assertTrue(form.is_valid(), form.errors)
        for seats in [0, 31, -1, "text", "1.5", ""]:
            form = CourseForm(dict(self.data, seats=seats))
            self.assertFalse(form.is_valid())
            self.assertIn("seats", form.errors)
        self.assertFalse(CourseForm(dict(self.data, title="X" * 101)).is_valid())

    def test_create_and_edit_preserve_single_record(self):
        self.assertContains(self.client.get("/"), "Курсов пока нет")
        self.assertEqual(self.client.get("/courses/new/").status_code, 200)
        self.assertRedirects(self.client.post("/courses/new/", self.data), "/")
        course = Course.objects.get()
        edit = f"/courses/{course.pk}/edit/"
        self.assertContains(self.client.get(edit), "Основы Python")
        self.assertRedirects(self.client.post(edit, dict(self.data, title="Продвинутый Python", seats=30)), "/")
        self.assertEqual(Course.objects.count(), 1)
        course.refresh_from_db()
        self.assertEqual(course.seats, 30)
        invalid = self.client.post(edit, dict(self.data, seats=31))
        self.assertContains(invalid, "Количество мест должно быть от 1 до 30.")
        self.assertContains(invalid, 'value="31"')
        self.assertContains(invalid, "Основы Python")
        course.refresh_from_db()
        self.assertEqual(course.title, "Продвинутый Python")
        self.assertContains(self.client.get("/"), "Продвинутый Python")
        self.assertEqual(self.client.get("/courses/9999/edit/").status_code, 404)

    def test_csrf(self):
        client = Client(enforce_csrf_checks=True)
        self.assertEqual(client.post("/courses/new/", self.data).status_code, 403)
        client.get("/courses/new/")
        self.assertRedirects(client.post("/courses/new/", dict(self.data, csrfmiddlewaretoken=client.cookies["csrftoken"].value)), "/")
