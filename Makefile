APP_NAME ?= sonarr

.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
.DEFAULT_GOAL := help

.PHONY: all
all: build test ## Build and test the container.

.PHONY: build
build: ## Build the container.
	podman build -t "${APP_NAME}" .

.PHONY: build-nc
build-nc: ## Build the container without cache.
	podman build --no-cache -t "${APP_NAME}" .

.PHONY: test
test: ## Test the container.
	podman run -it --rm --name "${APP_NAME}" "${APP_NAME}" \
		bash -c "/usr/bin/mono /opt/sonarr/bin/NzbDrone.exe -nobrowser -data /opt/sonarr & \
			   test.sh -t 30 -u http://localhost:8989/ -e Sonarr"

.PHONY: clean
clean: ## Clean the generated files/images.
	podman rmi "${APP_NAME}"
