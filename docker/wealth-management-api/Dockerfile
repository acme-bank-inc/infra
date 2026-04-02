# Stub Dockerfile for wealth-management-api (Flask)
# Replace with actual build from github.com/acme-bank-inc/wealth-management-api
FROM python:3.12-slim
WORKDIR /app
COPY . .
RUN pip install --no-cache-dir -r requirements.txt 2>/dev/null || true
EXPOSE 5000
CMD ["python", "-m", "flask", "run", "--host=0.0.0.0", "--port=5000"]
