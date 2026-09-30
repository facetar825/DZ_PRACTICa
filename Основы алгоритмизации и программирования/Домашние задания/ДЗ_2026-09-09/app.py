from flask import Flask, render_template, abort

app = Flask(__name__)

# Наш каталог фильмов
movies = [
    {
        "id": 1,
        "title": "Побег из Шоушенка",
        "year": 1994,
        "rating": 9.3,
        "genre": "Драма",
        "description": "Бухгалтер Энди Дюфрейн обвинён в убийстве собственной жены и её любовника. Оказавшись в тюрьме, он знакомится с контрабандистом Эллисом Бойдом..."
    },
    {
        "id": 2,
        "title": "Крёстный отец",
        "year": 1972,
        "rating": 9.2,
        "genre": "Криминал",
        "description": "Криминальная сага, повествующая о жизни семьи Корлеоне — могущественного клана, контролирующего организованную преступность в Нью-Йорке."
    }

]

@app.route('/')
def index():

    return render_template('index.html', movies=movies)

@app.route('/movie/<int:movie_id>')
def movie_detail(movie_id):

    movie = next((m for m in movies if m["id"] == movie_id), None)
    if movie is None:
        abort(404)  # Если не нашли — ошибка 404
    return render_template('movie.html', movie=movie)

if __name__ == '__main__':
    app.run(debug=True)