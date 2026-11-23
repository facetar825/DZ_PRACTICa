from datetime import date
from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator


def latest_year():
    return date.today().year + 5


class Director(models.Model):
    name = models.CharField("Имя", max_length=150)
    country = models.CharField("Страна", max_length=100)
    def __str__(self):
        return self.name


class Genre(models.Model):
    name = models.CharField("Название", max_length=80, unique=True)
    def __str__(self):
        return self.name


class Movie(models.Model):
    title = models.CharField("Название", max_length=200)
    year = models.IntegerField("Год", validators=[MinValueValidator(1888), MaxValueValidator(latest_year)])
    rating = models.IntegerField("Рейтинг", validators=[MinValueValidator(0), MaxValueValidator(10)])
    duration_minutes = models.IntegerField("Длительность, мин", validators=[MinValueValidator(1), MaxValueValidator(1440)])
    director = models.ForeignKey(Director, verbose_name="Режиссёр", on_delete=models.CASCADE)
    genre = models.ForeignKey(Genre, verbose_name="Жанр", on_delete=models.PROTECT)
    def __str__(self):
        return f"{self.title} ({self.year}) — {self.director}"
