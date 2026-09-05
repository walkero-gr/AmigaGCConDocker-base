include ../_common/help.mk

# Target architecture for the build
ARCH=ppc-morphos

# GCC version to use
GCC?=11

# Release version
REL?=1.0.0

REPO=walkero/amigagccondocker
TAG=mos-gcc$(GCC)-base-$(REL)
VOLUMES=-v "${PWD}/out":/opt/out
WORKSPACE=-w /packages
NAME=$(TAG)

#####################################################################
##@ Build dev environment

.PHONY: build
build: ## Build the main dev environment image
	docker buildx build -f ./Dockerfile \
		--progress plain \
		-t $(REPO):$(TAG) \
		--build-arg GCC_VER=$(GCC) .

.PHONY: buildnc
buildnc: ## Build the main dev environment image with no-cache
	docker buildx build --no-cache -f ./Dockerfile \
		-t $(REPO):$(TAG) \
		--build-arg GCC_VER=$(GCC) .

.PHONY: shell
shell: ## Create a container with the latest Docker image and use it
	docker run -it --rm --name $(NAME) $(VOLUMES) $(WORKSPACE) $(REPO):$(TAG) /bin/bash

#####################################################################
##@ Build dependencies help image

.PHONY: build-deps
build-deps: ## Build the dependencies image
	docker buildx build --no-cache -f ./Dockerfile.deps \
		--progress plain \
		-t $(REPO):$(ARCH)-deps .

#####################################################################
##@ Helpers

.PHONY: test
test: ## Test the Docker image with snyk
	snyk test --docker $(REPO):$(TAG) --file=Dockerfile
