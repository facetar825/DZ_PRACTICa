from flask import Flask, render_template

app = Flask(__name__)

SUBSYSTEMS = [
    {"name": "Двигатели", "status": "ok", "value": 42, "unit": "°C"},
    {"name": "Антенна", "status": "warning", "value": 67, "unit": "°C"},
    {"name": "Научный отсек", "status": "critical", "value": 96, "unit": "°C"},
    {"name": "Навигация", "status": "ok", "value": 35, "unit": "°C"},
]


@app.get("/")
def index():
    return render_template("index.html", battery=64, subsystems=SUBSYSTEMS)


if __name__ == "__main__":
    app.run(port=5007)
