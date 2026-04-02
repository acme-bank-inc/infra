#!/bin/bash
# EC2 user data script for Amazon Linux 2023
# Installs Docker, docker compose, clones repos, and starts services

set -euo pipefail

# Install Docker and git
dnf update -y
dnf install -y docker git
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

# Install Docker Compose plugin
mkdir -p /usr/libexec/docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/libexec/docker/cli-plugins/docker-compose
chmod +x /usr/libexec/docker/cli-plugins/docker-compose

# Install Docker Buildx plugin (0.17.0+ required by compose)
curl -SL https://github.com/docker/buildx/releases/download/v0.21.2/buildx-v0.21.2.linux-amd64 \
  -o /usr/libexec/docker/cli-plugins/docker-buildx
chmod +x /usr/libexec/docker/cli-plugins/docker-buildx

# Create working directory
mkdir -p /opt/acme-bank/apps
cd /opt/acme-bank

# Clone all application repos
REPOS=(
  banking-api
  mobile-banking-api
  wealth-management-api
  internal-compliance-api
  online-banking-portal
  internal-admin-portal
)

for repo in "${REPOS[@]}"; do
  git clone "https://github.com/acme-bank-inc/${repo}.git" "/opt/acme-bank/apps/${repo}" || true
done

# Clone the infra repo (contains docker compose and nginx config)
git clone "https://github.com/acme-bank-inc/infra.git" /opt/acme-bank/infra || true

cd /opt/acme-bank/infra

# Create .env with Auth0 config
cat > .env << 'ENVEOF'
AUTH0_DOMAIN=acme-bank-inc.us.auth0.com
AUTH0_AUDIENCE=https://api.acmebank.com
VITE_AUTH0_CLIENT_ID=cnCLsJ9gqA5AJKcndmUBdbZUf5eWFwh3
ENVEOF

# Start all services
docker compose up -d --build
