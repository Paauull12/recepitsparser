FROM python:3.10

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip
WORKDIR /app

COPY . /app

RUN pip install -e .

RUN mkdir -p /app/media

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]

EXPOSE 80

CMD ["gunicorn", "--bind", "0.0.0.0:80", "storage_service.wsgi:application", "--timeout", "120", "--log-level", "debug"]

