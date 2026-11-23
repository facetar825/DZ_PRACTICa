from django.shortcuts import redirect, render
from .forms import DirectorForm, GenreForm, MovieForm
from .models import Genre, Movie


def movie_list(request):
    movies = Movie.objects.select_related("director", "genre")
    query = request.GET.get("q", "").strip()
    genre = request.GET.get("genre", "")
    if query:
        movies = movies.filter(title__icontains=query)
    if genre.isdecimal():
        # Длинный недоверенный ID не передаём в SQLite как целое.
        if len(genre) <= 18:
            movies = movies.filter(genre_id=int(genre))
        else:
            movies = movies.none()
    sorts = {"title": "title", "year": "-year", "rating": "-rating", "duration": "duration_minutes"}
    sort = request.GET.get("sort", "title")
    movies = movies.order_by(sorts.get(sort, "title"), "id")
    return render(request, "cinema/list.html", {
        "movies": movies, "genres": Genre.objects.all().order_by("name"),
        "q": query, "selected_genre": genre, "sort": sort,
    })


def add(request, kind):
    forms = {"director": (DirectorForm, "Добавить режиссёра"),
             "genre": (GenreForm, "Добавить жанр"), "movie": (MovieForm, "Добавить фильм")}
    form_class, title = forms[kind]
    form = form_class(request.POST if request.method == "POST" else None)
    if request.method == "POST" and form.is_valid():
        form.save()
        return redirect("movies")
    return render(request, "cinema/form.html", {"form": form, "title": title})
