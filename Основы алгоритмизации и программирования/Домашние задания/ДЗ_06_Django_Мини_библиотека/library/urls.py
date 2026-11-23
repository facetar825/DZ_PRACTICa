from django.urls import path
from django.views.generic import RedirectView
from .views import book_create, book_list

urlpatterns = [path("", RedirectView.as_view(pattern_name="book_list", permanent=False)), path("books/", book_list, name="book_list"), path("books/new/", book_create, name="book_create")]
