#!/bin/bash
# EC2 user data script for Amazon Linux 2023
# Installs Docker, docker compose, clones repos, and starts services

set -euo pipefail

# Install Docker
dnf update -y
dnf install -y docker git
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

# Install Docker Compose plugin
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Create working directory
mkdir -p /opt/acme-bank
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

# Create .env file from example (operator should update with real values)
if [ -f .env.example ] && [ ! -f .env ]; then
  cp .env.example .env
fi

# Start all services
docker compose up -d --build
