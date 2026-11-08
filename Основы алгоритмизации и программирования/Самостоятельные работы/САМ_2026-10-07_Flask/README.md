# Список дел с напоминаниями

Самостоятельная работа от 07.10.2026. Flask, Flask-SQLAlchemy, SQLite, Jinja2 и Flask-WTF. Добавление, редактирование, удаление и отметка выполнения задач. На главной задачи сгруппированы по дедлайну, есть счётчик выполнения. Дополнительная функция — тёмная тема с сохранением выбора в браузере.

## Локальный запуск

```powershell
py -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe app.py
```

Открыть http://127.0.0.1:5000/. База сохраняется в `instance/tasks.sqlite3`. Дедлайны вводятся в местном времени (по умолчанию Asia/Irkutsk, можно настроить через `TODO_TIME_ZONE`). Приложение рассчитано на одного пользователя.

## Docker

Команды выполняются из этой папки. Именованный том сохраняет задачи при пересоздании контейнера.

```powershell
docker build -t homework-todo:1.0 .
docker run --rm -p 127.0.0.1:5000:5000 --mount source=homework-todo-data,target=/app/instance homework-todo:1.0
```
