import math
import os
import secrets

from flask import Flask, redirect, render_template, session, url_for
from flask_wtf import FlaskForm
from wtforms import FloatField, IntegerField, SubmitField
from wtforms.validators import InputRequired, NumberRange, ValidationError


def finite_number(form, field):
    if field.data is not None and not math.isfinite(field.data):
        raise ValidationError('Введите конечное число.')


class BMIForm(FlaskForm):
    weight = FloatField('Вес, кг', validators=[
        InputRequired(message='Введите вес.'), finite_number,
        NumberRange(min=20, max=300, message='Вес должен быть от 20 до 300 кг.')])
    height = IntegerField('Рост, см', validators=[
        InputRequired(message='Введите рост.'),
        NumberRange(min=100, max=250, message='Рост должен быть от 100 до 250 см.')])
    age = IntegerField('Возраст', validators=[
        InputRequired(message='Введите возраст.'),
        NumberRange(min=1, max=120, message='Возраст должен быть от 1 до 120 лет.')])
    submit = SubmitField('Рассчитать ИМТ')


def bmi_category(value):
    if value < 18.5:
        return 'Недовес', 'low'
    if value < 25:
        return 'Норма', 'normal'
    if value <= 30:
        return 'Избыток', 'high'
    return 'Ожирение', 'very-high'


def create_app(config=None):
    app = Flask(__name__)
    app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY') or secrets.token_hex(32)
    if config:
        app.config.update(config)

    @app.route('/', methods=['GET', 'POST'])
    def index():
        form = BMIForm()
        if form.validate_on_submit():
            value = form.weight.data / (form.height.data / 100) ** 2
            category, style = bmi_category(value)
            session['result'] = dict(weight=form.weight.data, height=form.height.data,
                                     age=form.age.data, bmi=f'{value:.1f}',
                                     category=category, style=style)
            return redirect(url_for('result'))
        return render_template('index.html', form=form)

    @app.get('/result')
    def result():
        data = session.get('result')
        if data is None:
            return redirect(url_for('index'))
        return render_template('result.html', result=data)

    return app


app = create_app()

if __name__ == '__main__':
    app.run(port=5000)
