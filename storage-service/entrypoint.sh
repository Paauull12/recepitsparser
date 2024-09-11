#!/bin/sh

echo "Applying database migrations..."
python manage.py makemigrations
python manage.py migrate
echo "Migrations done"

echo "Aștept pentru ca textdetectapi să fie sănătos..."
until curl -f http://textdetectapi:80/api/process-image/; do
  echo "textdetectapi nu este sănătos încă. Reîncercare..."
  sleep 10
done

echo "textdetectapi este sănătos. Pornind aplicația..."

echo "Starting Gunicorn..."
exec "$@"
