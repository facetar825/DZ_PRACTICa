from datetime import date, timedelta

from flask import Flask, render_template, request

app = Flask(__name__)

days = [
    ("Пн", "Понедельник"),
    ("Вт", "Вторник"),
    ("Ср", "Среда"),
    ("Чт", "Четверг"),
    ("Пт", "Пятница"),
]

schedule = {
    0: [
        ("09:00–10:30", "Основы алгоритмизации и программирования", "301"),
        ("10:40–12:10", "Теория баз данных Microsoft SQL Server", "305"),
        ("12:40–14:10", "Английский язык", "204"),
    ],
    1: [
        ("09:00–10:30", "Разработка программных модулей", "302"),
        ("10:40–12:10", "Тестирование программных модулей", "301"),
    ],
    2: [
        ("09:00–10:30", "Теория баз данных Microsoft SQL Server", "305"),
        ("10:40–12:10", "Разработка мобильных приложений", "302"),
        ("12:40–14:10", "Физическая культура", "Спортзал"),
    ],
    3: [
        ("09:00–10:30", "Основы алгоритмизации и программирования", "301"),
        ("10:40–12:10", "Платформа Microsoft .NET и язык C#", "302"),
    ],
    4: [
        ("09:00–10:30", "Разработка приложений Windows Forms и WPF", "302"),
        ("10:40–12:10", "Объектно-ориентированное проектирование", "301"),
        ("12:40–14:10", "Разработка мобильных приложений", "305"),
    ],
}


@app.route("/")
def index():
    today = date.today()
    monday = today - timedelta(days=today.weekday())
    selected = request.args.get("day", default=min(today.weekday(), 4), type=int)
    if selected not in schedule:
        selected = 0
    dates = [monday + timedelta(days=i) for i in range(5)]
    return render_template(
        "index.html",
        days=days,
        dates=dates,
        selected=selected,
        lessons=schedule[selected],
        today=today,
    )


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000)
