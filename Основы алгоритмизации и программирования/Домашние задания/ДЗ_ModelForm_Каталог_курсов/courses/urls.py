from django.urls import path
from .views import course_edit, course_list

urlpatterns = [
    path("", course_list),
    path("courses/", course_list, name="course_list"),
    path("courses/add/", course_edit, name="course_create"),
    path("courses/new/", course_edit),
    path("courses/<int:pk>/edit/", course_edit, name="course_edit"),
]
