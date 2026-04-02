.PHONY: plan apply destroy docker-up docker-down docker-build init

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

docker-build: ## Build all Docker images
	docker compose build

docker-up: ## Start all services locally
	docker compose up -d

docker-down: ## Stop all services locally
	docker compose down

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
