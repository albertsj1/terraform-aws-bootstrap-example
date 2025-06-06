# First stage: build
FROM python:3.12-alpine as builder

ENV PIP_DEFAULT_TIMEOUT=100 \
    # Allow statements and log messages to immediately appear
    PYTHONUNBUFFERED=1 \
    # disable a pip version check to reduce run-time & log-spam
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    # cache is useless in docker image, so disable to reduce image size
    PIP_NO_CACHE_DIR=1 \
    PDM_VERSION=2.10.4

WORKDIR /app

# Copy pdm files
COPY pyproject.toml pdm.lock ./
COPY src ./src

# Install PDM
RUN pip install -U pip
RUN pip install pdm==${PDM_VERSION}

# Install dependencies
RUN pdm install --prod --no-lock --no-editable

# Second stage: runtime
FROM python:3.12-alpine

WORKDIR /app

RUN addgroup --system --gid 1001 fibuser && \
    adduser --system --uid 1001 \
    --ingroup fibuser \
    --no-create-home \
    --disabled-password \
    --gecos '' \
    fibuser

COPY --from=builder --chown=fibuser:fibuser /app/build/lib /app/pkgs

# Change to non-root user
USER fibuser

ENV PYTHONPATH=/app/pkgs

# Expose port
EXPOSE 8000

# Run the application
CMD ["python3", "-m", "main"]
