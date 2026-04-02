# Acme Bank Inc Infrastructure

Infrastructure repository for Acme Bank Inc, a test organization used for ETM ASMP testing. This repo contains Terraform configurations for AWS deployment and Docker setup for local development.

## Architecture

All services run on AWS ECS Fargate behind a single Application Load Balancer. The setup uses a minimal VPC with one public subnet in a single availability zone. There is no redundancy or high availability because this is a test environment where cost is the priority.

### Services

| Service | Repository | Local Port |
|---------|-----------|------------|
| Banking API | acme-bank-inc/banking-api | 8081 |
| Mobile Banking API | acme-bank-inc/mobile-banking-api | 8082 |
| Wealth Management API | acme-bank-inc/wealth-management-api | 8083 |
| Online Banking Portal | acme-bank-inc/online-banking-portal | 8084 |
| Internal Compliance API | acme-bank-inc/internal-compliance-api | 8085 |
| Internal Admin Portal | acme-bank-inc/internal-admin-portal | 8086 |

## Local Development

Run all services locally using Docker Compose:

```bash
make docker-up      # Start all services
make docker-down    # Stop all services
make docker-build   # Rebuild all images
```

Each service is available on its own port (see table above). The Dockerfiles in `docker/` are stubs that reference the source repositories. Replace them with actual build steps once service code is ready.

## AWS Deployment

### Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform >= 1.5 installed

### Usage

```bash
make init      # Initialize Terraform providers
make plan      # Preview infrastructure changes
make apply     # Apply the plan
make destroy   # Tear down all resources
```

### Configuration

Edit `terraform/variables.tf` or pass overrides on the command line:

```bash
cd terraform && terraform plan -var="environment=staging"
```

### Cost Notes

This configuration is intentionally minimal to keep costs low:

- Fargate tasks use 0.25 vCPU and 512 MB memory each
- Single AZ deployment with no NAT gateway
- No private subnets (all tasks get public IPs)
- Container Insights disabled
- CloudWatch logs retained for 7 days only
- No HTTPS (no ACM certificate costs)

## Directory Structure

```
terraform/          # AWS infrastructure as code
  main.tf           # Provider configuration
  variables.tf      # Input variables
  vpc.tf            # VPC, subnet, routing
  security.tf       # Security groups
  alb.tf            # Load balancer and routing rules
  ecs.tf            # ECS cluster, tasks, services
  outputs.tf        # Output values
docker/             # Dockerfile stubs per service
docker-compose.yml  # Local development compose file
Makefile            # Build and deployment targets
```
