# Stub Dockerfile for wealth-management-api
# Replace with actual build from github.com/acme-bank-inc/wealth-management-api
FROM node:20-alpine
WORKDIR /app
COPY . .
RUN npm install --production 2>/dev/null || true
EXPOSE 8080
CMD ["node", "server.js"]
