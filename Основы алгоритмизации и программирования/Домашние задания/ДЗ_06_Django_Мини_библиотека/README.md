# ДЗ 6 Django Мини-библиотека

## Запуск

В этой папке:

```powershell
py -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe manage.py migrate
.\.venv\Scripts\python.exe manage.py loaddata authors
.\.venv\Scripts\python.exe manage.py runserver 8003
```

Открыть http://127.0.0.1:8003/books/. Страница /books/new/ показывает BookForm. После корректного POST книга сохраняется, затем выполняется редирект на список. При ошибках остаются введённые значения и сообщения валидации.

Author содержит name до 100 символов. Book содержит title, author с CASCADE и целочисленный year. Дополнительно год ограничен диапазоном 1–9999. Список использует Book.objects.select_related("author").

Фикстура authors добавляет двух авторов в новую базу. Для управления авторами доступна админка /admin/ после команды python manage.py createsuperuser.

## Проверка

python manage.py test проверяет показ пустого списка и формы, сохранение книги и редирект, вывод названия, автора и года, ошибки данных, CSRF, select_related и CASCADE.
