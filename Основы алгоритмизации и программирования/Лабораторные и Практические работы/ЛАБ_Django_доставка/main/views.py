from django.shortcuts import render
from .forms import DeliveryForm


def index(request):
    form = DeliveryForm(request.POST if request.method == "POST" else None)
    total = form.total() if request.method == "POST" and form.is_valid() else None
    return render(request, "demo/delivery.html", {"form":form, "total":total})
