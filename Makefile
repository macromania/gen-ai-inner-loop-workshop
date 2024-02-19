SHELL := /bin/bash

.PHONY: help
.DEFAULT_GOAL := help
.ONESHELL: # Applies to every target in the file https://www.gnu.org/software/make/manual/html_node/One-Shell.html
MAKEFLAGS += --silent # https://www.gnu.org/software/make/manual/html_node/Silent.html

help: ## 💬 This help message :)
	grep -E '[a-zA-Z_-]+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-23s\033[0m %s\n\n", $$1, $$2}'

setup-local-env: ## 🐍 Create a virtual environment and install dependencies
	@echo "🐍 Creating a virtual environment..."
	python -m venv .venv

	@echo "🐍 Virtual environment created. Running 'source .venv/bin/activate' to activate it."

	@echo "🐍 Installing dependencies..."
	. .venv/bin/activate; pip install -r requirements.txt

	@echo "🐍 Setting up notebooks filtering"
	nbstripout --install --attributes .gitattributes

chat-hello-world-flow: ## 💬 Run the hello world flow in terminal
	@echo "🚀 Running the hello world flow..."
	@echo "🚀 Creating the connection..."
	
	# Reads the .env file, removes any comments (lines starting with #), and formats the remaining lines as VARNAME=value strings
	export $(shell cat .env | sed 's/#.*//g' | xargs) \
	. .venv/bin/activate; pf connection create -f app/flows/hello-world-chat/azure_openai.yaml --set api_key=$$AZURE_OPENAI_API_KEY api_base=$$AZURE_OPENAI_ENDPOINT;
	
	@echo "🚀 Connection created!"
	
	@echo "🚀 Running the flow..."
	
	. .venv/bin/activate; pf flow test --flow app/flows/hello-world-chat --interactive

chat-hello-world-app: ## 🖥️  Run the hello world flow as local server app
	@echo "🚀 Running the hello world app..."
	@echo "🚀 Creating the connection..."
	
	# Reads the .env file, removes any comments (lines starting with #), and formats the remaining lines as VARNAME=value strings
	export $(shell cat .env | sed 's/#.*//g' | xargs) \
	. .venv/bin/activate; pf connection create -f app/flows/hello-world-chat/azure_openai.yaml --set api_key=$$AZURE_OPENAI_API_KEY api_base=$$AZURE_OPENAI_ENDPOINT;
	
	@echo "🚀 Connection created!"
	
	@echo "🚀 Running the server..."
	
	. .venv/bin/activate; pf flow serve --source app/flows/hello-world-chat/ --port 8080 --host localhost