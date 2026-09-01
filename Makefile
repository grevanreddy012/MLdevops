.PHONY: help install generate-data train run-api run-ui run-simulator run-stack test build-docker lint security-scan

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install: ## Install python dependencies
	pip install -r requirements.txt
	pip install -r ui/requirements.txt

generate-data: ## Generate the synthetic banking transactions dataset
	python scripts/generate_data.py

train: ## Train the ML models and generate evaluation reports
	python pipelines/train_pipeline.py

run-api: ## Run the FastAPI application locally
	uvicorn api.main:app --reload --host 0.0.0.0 --port 8000

run-ui: ## Run the Streamlit SOC Dashboard locally
	cd ui && streamlit run app.py --server.port 8501 --server.address 0.0.0.0

run-simulator: ## Run the standalone stream simulator
	python scripts/stream_simulator.py

run-stack: ## Run the full stack via Docker Compose (API + UI + Prometheus + Grafana)
	docker-compose -f infrastructure/docker-compose.yml up -d

test: ## Run unit and integration tests
	pytest tests/

build-docker: ## Build the Docker images
	docker-compose -f infrastructure/docker-compose.yml build

lint: ## Run linter and formatter
	black .
	flake8 src/ api/ scripts/ pipelines/ ui/

security-scan: ## Run security scans locally
	bandit -r src/ api/ pipelines/ ui/
	trivy fs .
