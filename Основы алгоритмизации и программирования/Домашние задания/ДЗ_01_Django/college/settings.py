import os
import secrets

SECRET_KEY = os.environ.get("DJANGO_SECRET_KEY") or secrets.token_hex(32)
DEBUG = False
ALLOWED_HOSTS = os.environ.get("DJANGO_ALLOWED_HOSTS", "localhost,127.0.0.1,[::1]").split(",")
ROOT_URLCONF = "college.urls"
WSGI_APPLICATION = "college.wsgi.application"
INSTALLED_APPS = ["schedule"]
TEMPLATES = [{
    "BACKEND": "django.template.backends.django.DjangoTemplates",
    "APP_DIRS": True,
}]
MIDDLEWARE = ["django.middleware.security.SecurityMiddleware"]
LANGUAGE_CODE = "ru"
TIME_ZONE = "Asia/Irkutsk"
USE_TZ = True
