from django import forms
from .models import Course


class CourseForm(forms.ModelForm):
    class Meta:
        model = Course
        fields = ["title", "description", "seats"]

    def clean_seats(self):
        seats = self.cleaned_data["seats"]
        if not 1 <= seats <= 30:
            raise forms.ValidationError("Количество мест должно быть от 1 до 30.")
        return seats
