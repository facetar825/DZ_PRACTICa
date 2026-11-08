FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && useradd --create-home todo \
    && install -d -o todo -g todo /app/instance
COPY app.py forms.py models.py ./
COPY templates/ templates/
COPY static/ static/
USER todo
VOLUME ["/app/instance"]
EXPOSE 5000
CMD ["waitress-serve", "--listen=0.0.0.0:5000", "--call", "app:create_app"]
