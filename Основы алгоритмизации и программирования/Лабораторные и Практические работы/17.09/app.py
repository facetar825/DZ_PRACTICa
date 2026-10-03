import os
import secrets
import sqlite3
from pathlib import Path

from flask import Flask, abort, flash, g, redirect, render_template, request, url_for
from flask_wtf import CSRFProtect, FlaskForm
from wtforms import StringField, TextAreaField
from wtforms.validators import DataRequired, Length


class TaskForm(FlaskForm):
    title = StringField('Название', filters=[lambda s: s.strip() if s else s], validators=[
        DataRequired(message='Введите название задачи.'),
        Length(max=150, message='Не больше 150 символов.')])
    description = TextAreaField('Описание', filters=[lambda s: s.strip() if s else s],
                                validators=[Length(max=2000, message='Не больше 2000 символов.')])
    category = StringField('Категория', filters=[lambda s: s.strip() if s else s], validators=[
        DataRequired(message='Введите категорию.'),
        Length(max=60, message='Не больше 60 символов.')])


def create_app(config=None):
    app = Flask(__name__)
    app.config.update(SECRET_KEY=os.environ.get('SECRET_KEY') or secrets.token_hex(32),
                      DATABASE=str(Path(app.instance_path) / 'tasks.sqlite'))
    if config:
        app.config.update(config)
    CSRFProtect(app)
    Path(app.config['DATABASE']).parent.mkdir(parents=True, exist_ok=True)

    def get_db():
        if 'db' not in g:
            g.db = sqlite3.connect(app.config['DATABASE'])
            g.db.row_factory = sqlite3.Row
        return g.db

    @app.teardown_appcontext
    def close_db(error=None):
        db = g.pop('db', None)
        if db is not None:
            db.close()

    with app.app_context():
        get_db().executescript('''
            CREATE TABLE IF NOT EXISTS tasks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                description TEXT NOT NULL DEFAULT '',
                done BOOLEAN NOT NULL DEFAULT 0 CHECK (done IN (0, 1)),
                category TEXT NOT NULL
            );
        ''')
        get_db().commit()

    def find_task(task_id):
        task = get_db().execute('SELECT * FROM tasks WHERE id = ?', (task_id,)).fetchone()
        if task is None:
            abort(404)
        return task

    def back_to_list():
        return redirect(url_for('index', category=request.form.get('filter_category', ''),
                                sort=request.form.get('sort', 'newest')))

    @app.get('/')
    def index():
        db = get_db()
        category = request.args.get('category', '').strip()
        sort = request.args.get('sort', 'newest')
        orders = {'newest': 'id DESC', 'unfinished': 'done ASC, id DESC',
                  'finished': 'done DESC, id DESC'}
        if sort not in orders:
            sort = 'newest'
        query, params = 'SELECT * FROM tasks', ()
        if category:
            query += ' WHERE category = ?'
            params = (category,)
        tasks = db.execute(query + ' ORDER BY ' + orders[sort], params).fetchall()
        categories = [r['category'] for r in db.execute(
            'SELECT DISTINCT category FROM tasks ORDER BY category COLLATE NOCASE')]
        stats = db.execute('SELECT COUNT(*) AS total, COALESCE(SUM(done), 0) AS done FROM tasks').fetchone()
        return render_template('index.html', tasks=tasks, categories=categories,
                               category=category, sort=sort, stats=stats)

    @app.route('/add', methods=['GET', 'POST'])
    def add():
        form = TaskForm()
        if form.validate_on_submit():
            db = get_db()
            db.execute('INSERT INTO tasks (title, description, category) VALUES (?, ?, ?)',
                       (form.title.data, form.description.data or '', form.category.data))
            db.commit()
            flash('Задача добавлена.')
            return redirect(url_for('index'))
        return render_template('form.html', form=form, editing=False)

    @app.route('/tasks/<int:task_id>/edit', methods=['GET', 'POST'])
    def edit(task_id):
        task = find_task(task_id)
        form = TaskForm(data=dict(task) if request.method == 'GET' else None)
        if form.validate_on_submit():
            db = get_db()
            db.execute('UPDATE tasks SET title = ?, description = ?, category = ? WHERE id = ?',
                       (form.title.data, form.description.data or '', form.category.data, task_id))
            db.commit()
            flash('Изменения сохранены.')
            return redirect(url_for('index'))
        return render_template('form.html', form=form, editing=True)

    @app.post('/tasks/<int:task_id>/toggle')
    def toggle(task_id):
        find_task(task_id)
        db = get_db()
        db.execute('UPDATE tasks SET done = 1 - done WHERE id = ?', (task_id,))
        db.commit()
        return back_to_list()

    @app.post('/tasks/<int:task_id>/delete')
    def delete(task_id):
        find_task(task_id)
        db = get_db()
        db.execute('DELETE FROM tasks WHERE id = ?', (task_id,))
        db.commit()
        flash('Задача удалена.')
        return back_to_list()

    return app


app = create_app()

if __name__ == '__main__':
    app.run(port=5001)
