import json
import secrets
from datetime import date, timedelta
from pathlib import Path
from threading import Lock

from flask import Flask, abort, flash, redirect, render_template, request, session, url_for
from werkzeug.security import check_password_hash, generate_password_hash

app = Flask(__name__)
app.secret_key = secrets.token_hex(32)
app.config.update(
    USERS_FILE=Path(__file__).with_name('users.json'),
    SESSION_COOKIE_HTTPONLY=True,
    SESSION_COOKIE_SAMESITE='Lax',
)
users_lock = Lock()
days = ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница']
short_days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт']
schedules = {
    '9/2-РПО-24/1': [
        [('09:00', 'Алгоритмизация и программирование', '301'), ('10:40', 'Базы данных SQL Server', '305')],
        [('09:00', 'Разработка программных модулей', '302'), ('10:40', 'Тестирование программных модулей', '301')],
        [('09:00', 'Разработка мобильных приложений', '302'), ('10:40', 'Английский язык', '204')],
        [('09:00', 'Алгоритмизация и программирование', '301'), ('10:40', 'Платформа .NET и C#', '302')],
        [('09:00', 'Windows Forms и WPF', '302'), ('10:40', 'Физическая культура', 'Спортзал')],
    ],
    'ИС-31': [
        [('09:00', 'Информационные системы', '201'), ('10:40', 'Проектирование баз данных', '205')],
        [('09:00', 'Компьютерные сети', '203'), ('10:40', 'Английский язык', '204')],
        [('09:00', 'Веб-разработка', '201'), ('10:40', 'Информационная безопасность', '203')],
        [('09:00', 'Проектирование баз данных', '205'), ('10:40', 'Информационные системы', '201')],
        [('09:00', 'Компьютерные сети', '203'), ('10:40', 'Физическая культура', 'Спортзал')],
    ],
    'ДИЗ-31': [
        [('09:00', 'Композиция', '401'), ('10:40', 'Рисунок', '402')],
        [('09:00', 'Типографика', '403'), ('10:40', 'История дизайна', '401')],
        [('09:00', 'Компьютерная графика', '404'), ('10:40', 'Английский язык', '204')],
        [('09:00', 'Проектирование интерфейсов', '404'), ('10:40', 'Живопись', '402')],
        [('09:00', 'Композиция', '401'), ('10:40', 'Физическая культура', 'Спортзал')],
    ],
}


def read_users():
    path = Path(app.config['USERS_FILE'])
    if not path.exists():
        return {}
    return json.loads(path.read_text(encoding='utf-8'))


def save_users(users):
    path = Path(app.config['USERS_FILE'])
    temporary = path.with_suffix('.tmp')
    temporary.write_text(json.dumps(users, ensure_ascii=False, indent=2), encoding='utf-8')
    temporary.replace(path)


@app.context_processor
def form_token():
    if 'csrf_token' not in session:
        session['csrf_token'] = secrets.token_hex(32)
    return {'csrf_token': session['csrf_token']}


@app.before_request
def check_token():
    if request.method == 'POST':
        token = session.get('csrf_token', '')
        if not token or not secrets.compare_digest(token, request.form.get('csrf_token', '')):
            abort(400)


@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        name = request.form.get('name', '').strip()
        login = request.form.get('login', '').strip().lower()
        password = request.form.get('password', '')
        group = request.form.get('group', '')
        if not 2 <= len(name) <= 80:
            flash('Введите имя длиной от 2 до 80 символов.')
        elif not 3 <= len(login) <= 30 or not all(c.isalnum() or c == '_' for c in login):
            flash('Логин: от 3 до 30 букв, цифр или знаков подчёркивания.')
        elif not 6 <= len(password) <= 128:
            flash('Пароль должен содержать от 6 до 128 символов.')
        elif password != request.form.get('confirm_password'):
            flash('Пароли не совпадают.')
        elif group not in schedules:
            flash('Выберите группу из списка.')
        else:
            with users_lock:
                users = read_users()
                if login in users:
                    flash('Этот логин уже занят.')
                else:
                    users[login] = {
                        'name': name,
                        'group': group,
                        'password_hash': generate_password_hash(password),
                    }
                    save_users(users)
                    flash('Аккаунт создан. Войдите с вашим логином и паролем.')
                    return redirect(url_for('login'))
    return render_template('register.html', groups=schedules)


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('login', '').strip().lower()
        password = request.form.get('password', '')
        user = read_users().get(username)
        if user and len(password) <= 128 and check_password_hash(user['password_hash'], password):
            session.clear()
            session['login'] = username
            return redirect(url_for('index'))
        flash('Неверный логин или пароль.')
    return render_template('login.html')


@app.route('/logout', methods=['POST'])
def logout():
    session.clear()
    return redirect(url_for('login'))


@app.route('/')
def index():
    user = read_users().get(session.get('login'))
    if not user:
        return redirect(url_for('login'))
    today = date.today()
    monday = today - timedelta(days=today.weekday())
    selected = request.args.get('day', min(today.weekday(), 4), type=int)
    if selected not in range(5):
        selected = 0
    dates = [monday + timedelta(days=i) for i in range(5)]
    return render_template(
        'schedule.html', user=user, days=days, short_days=short_days,
        selected=selected, dates=dates, lessons=schedules[user['group']][selected],
    )


if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5001)
