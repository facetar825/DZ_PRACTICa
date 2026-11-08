from datetime import timedelta

from django.shortcuts import render
from django.utils import timezone

from .data import DAYS, SCHEDULES


def index(request):
    today = timezone.localdate()
    monday = today - timedelta(days=today.weekday())
    group = request.GET.get("group", "")
    if group not in SCHEDULES:
        group = next(iter(SCHEDULES))
    try:
        day = int(request.GET.get("day", min(today.weekday(), 4)))
    except ValueError:
        day = 0
    if not 0 <= day < len(DAYS):
        day = 0

    week = [(name, monday + timedelta(days=index)) for index, name in enumerate(DAYS)]
    return render(request, "schedule/index.html", {
        "groups": SCHEDULES.keys(),
        "group": group,
        "week": week,
        "day": day,
        "day_name": DAYS[day],
        "lessons": SCHEDULES[group][day],
    })
