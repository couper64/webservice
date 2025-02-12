# Stage 1: Build dependencies
FROM python:3.11-slim AS builder

# Set the working directory inside the container.
WORKDIR /webservice

# Assuming this file is right next to Dockerfile.
COPY requirements.txt .

# Install dependencies without caching to reduce image size and store them in a temporary location.
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage 2: Final image
# Use the an optimised version of Linux with Python as the base image.
# This minimizes the final image size by installing dependencies in a temporary stage and copying only the necessary files. 🚀
FROM python:3.11-slim

# Set the working directory inside the container.
WORKDIR /webservice

# Copy installed dependencies from the builder stage to the final image to keep it lightweight.
COPY --from=builder /install /usr/local

# Assuming this folder is right next to Dockerfile.
COPY app ./app

# Set environment variables to avoid user interaction during package installation.
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Classic choice of port for FastAPI. It could be re-wired when starting the container.
EXPOSE 8000

# Why CMD and not ENTRYPOINT?
# CMD is used because it allows flexibility—if a user wants to override the command (e.g., run a different FastAPI app or shell into the container), they can do so easily. ENTRYPOINT, on the other hand, is more rigid and is typically used when the container should always run a specific executable.
# What does "app.main:app" mean?
# "app.main:app" tells Uvicorn to look for the FastAPI application inside the main.py file within the app package. The first app refers to the folder (app/), main refers to the Python module (main.py), and the second app is the FastAPI instance inside main.py (app = FastAPI()).
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
