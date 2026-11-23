from django.urls import path
from .views import add, movie_list
urlpatterns = [path("", movie_list, name="movies"), path("add/director/", add, {"kind":"director"}, name="add_director"), path("add/genre/", add, {"kind":"genre"}, name="add_genre"), path("add/movie/", add, {"kind":"movie"}, name="add_movie")]
