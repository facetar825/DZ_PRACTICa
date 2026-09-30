from flask import Flask, render_template, request, flash, redirect, url_for
import requests
from datetime import datetime

app = Flask(__name__)
app.secret_key = 'secret_key_for_flash_messages'  # Нужен для flash-сообщений


# Функция для получения координат города
def get_coordinates(city_name):
    url = f"https://geocoding-api.open-meteo.com/v1/search?name={city_name}&count=1&language=ru&format=json"
    try:
        response = requests.get(url)
        data = response.json()

        if "results" not in data or len(data["results"]) == 0:
            return None

        result = data["results"][0]
        return {
            "name": result.get("name"),
            "country": result.get("country", "—"),
            "latitude": result.get("latitude"),
            "longitude": result.get("longitude")
        }
    except Exception as e:
        print(f"Ошибка геокодинга: {e}")
        return None


# Функция для получения погоды по координатам
def get_weather(lat, lon):
    url = f"https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current=temperature_2m,relative_humidity_2m,wind_speed_10m&wind_speed_unit=kmh"
    try:
        response = requests.get(url)
        data = response.json()

        current = data.get("current", {})
        return {
            "temperature": current.get("temperature_2m"),
            "humidity": current.get("relative_humidity_2m"),
            "wind_speed": current.get("wind_speed_10m")
        }
    except Exception as e:
        print(f"Ошибка получения погоды: {e}")
        return None


# 1. Главная страница с формой
@app.route('/')
def index():
    return render_template('index.html')


# 2. Маршрут /weather (POST)
@app.route('/weather', methods=['POST'])
def weather():
    city = request.form.get('city', '').strip()

    if not city:
        flash('Пожалуйста, введите название города', 'error')
        return redirect(url_for('index'))

    # Получаем координаты
    location = get_coordinates(city)
    if not location:
        flash(f'Город "{city}" не найден. Попробуйте другой.', 'error')
        return redirect(url_for('index'))

    # Получаем погоду
    weather_data = get_weather(location["latitude"], location["longitude"])
    if not weather_data:
        flash('Не удалось получить данные о погоде. Попробуйте позже.', 'error')
        return redirect(url_for('index'))

    # Формируем результат
    result = {
        "city": location["name"],
        "country": location["country"],
        "temperature": weather_data["temperature"],
        "wind_speed": weather_data["wind_speed"],
        "humidity": weather_data["humidity"],
        "request_time": datetime.now().strftime("%d.%m.%Y %H:%M:%S")
    }

    return render_template('cart.html', weather=result)


if __name__ == '__main__':
    app.run(debug=True)