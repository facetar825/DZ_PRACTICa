from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator


class Author(models.Model):
    name = models.CharField("Имя", max_length=100)

    def __str__(self):
        return self.name


class Book(models.Model):
    title = models.CharField("Название", max_length=200)
    author = models.ForeignKey(Author, verbose_name="Автор", on_delete=models.CASCADE)
    year = models.IntegerField("Год издания", validators=[MinValueValidator(1), MaxValueValidator(9999)])

    def __str__(self):
        return self.title
