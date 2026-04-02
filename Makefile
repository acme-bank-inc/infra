.PHONY: init plan apply destroy docker-pull docker-up docker-down deploy ssh help

## Terraform targets

init: ## Initialize Terraform
	cd terraform && terraform init

plan: ## Run Terraform plan
	cd terraform && terraform plan -out=tfplan

apply: ## Apply Terraform changes
	cd terraform && terraform apply tfplan

destroy: ## Destroy all Terraform resources
	cd terraform && terraform destroy -auto-approve

## Docker targets

docker-pull: ## Pull all Docker images from GHCR
	docker compose pull

docker-up: ## Start all services locally
	docker compose up -d

docker-down: ## Stop all services locally
	docker compose down

deploy: ## Pull latest images and start all services
	docker compose pull && docker compose up -d

## Remote targets

ssh: ## SSH into the EC2 instance
	@echo "Run: $$(cd terraform && terraform output -raw ssh_command)"

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
