DS_VERSION=3.9
VCS_REF=$(shell git describe --tags --dirty --always)
BUILD_DATE=$(shell date +%Y-%m-%dT%H:%M:%S)
DOCKER_FULLTAG:=cmattoon/dead-souls:git-$(VCS_REF)
DOCKER_VTAG:=cmattoon/dead-souls:v$(DS_VERSION)
DOCKER_BUILD_ARGS=--build-arg=DS_VERSION=$(DS_VERSION) --build-arg=VCS_REF=$(VCS_REF) --build-arg=BUILD_DATE=$(BUILD_DATE)
.PHONY: help
help: ## display this message
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: docker
docker: ## build docker container
docker:
	docker build $(DOCKER_BUILD_ARGS) -t $(DOCKER_FULLTAG) .
	docker tag $(DOCKER_FULLTAG) $(DOCKER_VTAG)
