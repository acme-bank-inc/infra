# Stub Dockerfile for internal-admin-portal
# Replace with actual build from github.com/acme-bank-inc/internal-admin-portal
FROM node:20-alpine
WORKDIR /app
COPY . .
RUN npm install --production 2>/dev/null || true
EXPOSE 8080
CMD ["node", "server.js"]
