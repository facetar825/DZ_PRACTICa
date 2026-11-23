from django.contrib import admin
from .models import Director, Genre, Movie


@admin.register(Movie)
class MovieAdmin(admin.ModelAdmin):
    list_display = ("title", "year", "director", "genre", "rating", "duration_minutes")
    list_filter = ("genre", "year")
    search_fields = ("title", "director__name")
    list_select_related = ("director", "genre")

admin.site.register(Director)
admin.site.register(Genre)
