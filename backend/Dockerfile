FROM python:3.11-slim AS builder

WORKDIR /app

# Install only necessary build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install specific version of poetry with export support
RUN pip install --no-cache-dir poetry==1.5.1

# Copy only dependency files first for better caching
COPY pyproject.toml poetry.lock* ./

# Generate requirements.txt - using the correct syntax for poetry export
RUN poetry export --without-hashes --format=requirements.txt > requirements.txt

# Copy the rest of the application
COPY . .

# Final stage - much smaller
FROM python:3.11-slim

WORKDIR /app

# Install runtime dependencies only
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install directly with pip
COPY --from=builder /app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY --from=builder /app .

# Make startup script executable
RUN chmod +x /app/prestart.sh

# Set correct PYTHONPATH to ensure app imports work properly
ENV PYTHONPATH="${PYTHONPATH}:/app"

EXPOSE 8000

CMD ["bash", "-c", "cd /app && ./prestart.sh && uvicorn app.main:app --host 0.0.0.0 --port 8000"]