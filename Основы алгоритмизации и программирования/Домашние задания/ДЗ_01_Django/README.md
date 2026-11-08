# ДЗ 1 Django. Расписание занятий

Страница показывает учебное расписание на текущую неделю. Можно выбрать группу и день. Пример расписания перенесён из работы `ДЗ_2026-09-10`, данные находятся в `schedule/data.py`.

## Локальный запуск

```powershell
py -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe manage.py check
.\.venv\Scripts\python.exe manage.py runserver
```

Открыть http://127.0.0.1:8000/.

## Docker

```powershell
docker build -t homework-django-schedule:1.0 .
docker run --rm -p 127.0.0.1:8000:8000 homework-django-schedule:1.0
```

Для публикации выполни `docker login`, введи свой логин Docker Hub вместо `YOUR_DOCKER_ID` и запусти:

```powershell
docker tag homework-django-schedule:1.0 YOUR_DOCKER_ID/homework-django-schedule:1.0
docker push YOUR_DOCKER_ID/homework-django-schedule:1.0
```
