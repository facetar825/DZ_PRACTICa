from django.urls import path
from .views import course_edit, course_list

urlpatterns = [
    path("", course_list, name="course_list"),
    path("courses/new/", course_edit, name="course_create"),
    path("courses/<int:pk>/edit/", course_edit, name="course_edit"),
]
