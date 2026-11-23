from django import forms
from .models import Director, Genre, Movie


class DirectorForm(forms.ModelForm):
    class Meta:
        model = Director
        fields = ["name", "country"]


class GenreForm(forms.ModelForm):
    class Meta:
        model = Genre
        fields = ["name"]


class MovieForm(forms.ModelForm):
    class Meta:
        model = Movie
        fields = ["title", "year", "rating", "duration_minutes", "director", "genre"]
