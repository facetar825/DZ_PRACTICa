from flask_wtf import FlaskForm
from wtforms import DateTimeLocalField, SelectField, StringField, TextAreaField
from wtforms.validators import InputRequired, Length, ValidationError

from models import local_now

PRIORITIES = [("low", "Низкий"), ("medium", "Средний"), ("high", "Высокий")]


class TaskForm(FlaskForm):
    title = StringField(
        "Название", filters=[lambda value: (value or "").strip()],
        validators=[Length(min=1, max=200, message="Введите от 1 до 200 символов.")],
    )
    description = TextAreaField(
        "Описание", validators=[Length(max=4000, message="До 4000 символов.")],
    )
    deadline = DateTimeLocalField(
        "Дедлайн", validators=[InputRequired(message="Укажите дату и время.")],
    )
    priority = SelectField("Приоритет", choices=PRIORITIES, default="medium")

    def validate_deadline(self, field):
        if field.data is not None and field.data <= local_now():
            raise ValidationError("Дедлайн должен быть в будущем.")
