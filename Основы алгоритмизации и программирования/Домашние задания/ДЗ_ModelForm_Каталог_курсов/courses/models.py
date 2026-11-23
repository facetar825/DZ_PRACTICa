from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models


class Course(models.Model):
    title = models.CharField("Название", max_length=100)
    description = models.TextField("Описание")
    seats = models.IntegerField("Число мест", validators=[MinValueValidator(1), MaxValueValidator(30)])

    def __str__(self):
        return self.title
