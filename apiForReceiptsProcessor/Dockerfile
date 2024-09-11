# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set the working directory in the container
WORKDIR /code

# Copy the requirements file into the container
COPY requirements.txt /code/

# Install dependencies
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Copy the rest of the codebase into the container
COPY . /code/

# Expose the port the app runs on
EXPOSE 80

# Collect static files (optional, but recommended for production)
# Run Gunicorn and serve the Django app
CMD ["gunicorn", "--bind", "0.0.0.0:80", "apiForReceiptsProcessor.wsgi:application", "--timeout", "120", "--log-level", "debug"]
