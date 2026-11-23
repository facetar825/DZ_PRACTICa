from django.contrib import admin
from .models import Author, Book

admin.site.register(Author)


@admin.register(Book)
class BookAdmin(admin.ModelAdmin):
    list_display = ("title", "author", "year")
    search_fields = ("title", "author__name")
    list_select_related = ("author",)
