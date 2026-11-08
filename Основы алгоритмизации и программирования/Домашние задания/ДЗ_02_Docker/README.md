# ДЗ 2 Docker. Публикация образа Flask

Для задания выбран [Flask-трекер задач](<../../Самостоятельные работы/САМ_2026-10-07_Flask/>). Dockerfile находится рядом с исходным кодом трекера.

В PowerShell из этой папки:

```powershell
Set-Location -LiteralPath '../../Самостоятельные работы/САМ_2026-10-07_Flask'
docker build -t homework-todo:1.0 .
docker run --rm -p 127.0.0.1:5000:5000 --mount source=homework-todo-data,target=/app/instance homework-todo:1.0
```

Открой http://127.0.0.1:5000/, создай задачу и останови контейнер через Ctrl+C. Затем войди в Docker Hub и опубликуй образ. Замени `YOUR_DOCKER_ID` на имя своего аккаунта:

```powershell
docker login
docker tag homework-todo:1.0 YOUR_DOCKER_ID/homework-todo:1.0
docker push YOUR_DOCKER_ID/homework-todo:1.0
```

Для сдачи нужна ссылка на опубликованный образ: `https://hub.docker.com/r/YOUR_DOCKER_ID/homework-todo/tags`.
