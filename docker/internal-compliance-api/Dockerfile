# Stub Dockerfile for internal-compliance-api (FastAPI)
# Replace with actual build from github.com/acme-bank-inc/internal-compliance-api
FROM python:3.12-slim
WORKDIR /app
COPY . .
RUN pip install --no-cache-dir -r requirements.txt 2>/dev/null || true
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
