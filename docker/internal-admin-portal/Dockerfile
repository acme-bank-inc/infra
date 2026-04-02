# Stub Dockerfile for internal-admin-portal (Angular with nginx)
# Replace with actual build from github.com/acme-bank-inc/internal-admin-portal
FROM node:20-alpine AS build
WORKDIR /app
COPY . .
ARG VITE_AUTH0_DOMAIN
ARG VITE_AUTH0_CLIENT_ID
ARG VITE_AUTH0_AUDIENCE
RUN npm install 2>/dev/null || true
RUN npm run build 2>/dev/null || true

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
