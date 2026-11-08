FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && useradd --create-home schedule
COPY manage.py .
COPY college/ college/
COPY schedule/ schedule/
USER schedule
EXPOSE 8000
CMD ["waitress-serve", "--listen=0.0.0.0:8000", "college.wsgi:application"]
