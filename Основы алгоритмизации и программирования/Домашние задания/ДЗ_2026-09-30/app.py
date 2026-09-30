from flask import Flask, render_template, session, redirect, url_for, flash

app = Flask(__name__)
# secret_key ОБЯЗАТЕЛЕН для работы сессий — им шифруются cookie
app.secret_key = 'change-me-to-something-random'


@app.route('/')
def index():
    # 1. Читаем текущее значение счётчика из сессии.
    #    Если ключа нет — возвращаем 0.
    count = session.get('counter', 0)

    # 2. Увеличиваем на 1 при каждом заходе
    count += 1

    # 3. Сохраняем обратно в сессию
    session['counter'] = count

    # 4. Передаем значение в шаблон
    return render_template('index.html', count=count)


@app.route('/reset', methods=['POST'])
def reset():
    # Удаляем ключ 'counter' из сессии
    session.pop('counter', None)
    flash('Счётчик сброшен!', 'success')
    return redirect(url_for('index'))


if __name__ == '__main__':
    app.run(debug=True)