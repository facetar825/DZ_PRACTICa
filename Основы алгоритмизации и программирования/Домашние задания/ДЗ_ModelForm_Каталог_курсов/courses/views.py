from django.shortcuts import get_object_or_404, redirect, render
from django.views.decorators.http import require_http_methods
from .forms import CourseForm
from .models import Course


def course_list(request):
    courses = Course.objects.order_by("title", "id")
    return render(request, "courses/list.html", {"courses": courses})


@require_http_methods(["GET", "POST"])
def course_edit(request, pk=None):
    course = get_object_or_404(Course, pk=pk) if pk is not None else None
    form = CourseForm(request.POST if request.method == "POST" else None, instance=course)
    if request.method == "POST" and form.is_valid():
        form.save()
        return redirect("course_list")
    return render(request, "courses/form.html", {"form": form, "course": course})
