from django.shortcuts import redirect, render
from .forms import BookForm
from .models import Book


def book_list(request):
    books = Book.objects.select_related("author").order_by("title", "id")
    return render(request, "library/list.html", {"books":books})


def book_create(request):
    form = BookForm(request.POST if request.method == "POST" else None)
    if request.method == "POST" and form.is_valid():
        form.save()
        return redirect("book_list")
    return render(request, "library/create.html", {"form":form})
