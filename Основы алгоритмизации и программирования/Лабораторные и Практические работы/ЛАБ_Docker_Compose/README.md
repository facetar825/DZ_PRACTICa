# Docker Compose и гостевая книга

Реализованы Flask, Flask-SQLAlchemy, SQLite, счётчик посещений, форма сообщений и /health. Сообщения экранируются Jinja2. В образе используется Python 3.12.

## Запуск через Docker

```powershell
docker compose up -d --build
docker compose ps
```

Открыть http://127.0.0.1:5000/. Compose подключает именованный том sqlite-data в /data, а исходник app.py подключён bind mount. DB_PATH внутри контейнера — /data/data.db.

После правок app.py перезапусти процесс командой docker compose restart web. Само подключение файла не включает автоматическую перезагрузку Flask.

## Проверка сохранения базы

Добавь сообщения и запусти docker compose down, затем docker compose up -d. Обычный down сохраняет именованный том. Команда с флагом -v удаляет том вместе с БД.

Чтобы проверить второй контейнер с той же базой, узнай имя тома в docker volume ls и подставь его:

```powershell
docker run --rm -d --name guestbook-second -p 127.0.0.1:5001:5000 -e DB_PATH=/data/data.db --mount source=ИМЯ_ТОМА,target=/data netlab-guestbook:1.0
```

Открой http://127.0.0.1:5001/ и сравни сообщения. После опыта останови дополнительный контейнер командой docker stop guestbook-second.

## ORM и экспорт файлов

```powershell
docker compose exec web python -c "from app import create_app, db, Message, Visit; a=create_app(); ctx=a.app_context(); ctx.push(); print(db.session.scalars(db.select(Message)).all()); print(db.session.scalar(db.select(db.func.count(Visit.id))))"
docker compose exec web ls /app
docker compose exec web ls /data
docker compose cp web:/data/data.db ./data.db
docker create --name guestbook-export netlab-guestbook:1.0
docker cp guestbook-export:/app ./extracted-app
```

## Docker Hub

После docker login подставь свой логин вместо YOUR_DOCKER_ID:

```powershell
docker tag netlab-guestbook:1.0 YOUR_DOCKER_ID/guestbook:1.0
docker push YOUR_DOCKER_ID/guestbook:1.0
```

## Локальная проверка

```powershell
py -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe tests.py
.\.venv\Scripts\python.exe app.py
```

При локальном запуске используется приложенный data.db. Он содержит учебные сообщения и посещения. Тест проверяет сохранение после пересоздания приложения, экранирование HTML, валидацию и увеличение счётчика. Проверка прошла. YAML проверен парсером.

## Незавершённая часть отчёта

Docker Engine и Compose на компьютере не обнаружены. Сборка и запуск контейнеров, экспорт из образа, проверка тома в Docker Desktop и отправка в Docker Hub ещё не выполнены. data.db создан локальным Flask-приложением.

Для завершения Word-отчёта нужны фактические скриншоты docker compose ps, гостевой книги, Stored data, двух контейнеров с общей БД, ORM-запросов и ls /app и ls /data, а также действующая ссылка на опубликованный образ. Сначала требуется установить и запустить Docker, войти в Docker Hub.
