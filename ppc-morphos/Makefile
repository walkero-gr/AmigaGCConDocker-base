OS=mos
# 8,9,10,11,15 can be used here
GCC?=11
REL?=1.0.0

REPO=walkero/amigagccondocker
TAG?=$(OS)-gcc$(GCC)-base-$(REL)
NAME=$(TAG)
VOLUMES?=-v "${PWD}/out":/opt/out
WORKSPACE=-w /packages
ARCH=ppc-morphos

.PHONY: build buildnc build-exp shell push logs clean test release

default: help

help:
	@echo "This makefile helps on building cross-compiling gcc for MorphOS PPC"
	@echo "The available parameters can be seen below:"
	@echo ""
	@echo "build            - Build the Docker image"
	@echo "buildnc          - Build the Docker image without using caching"
	@echo "shell            - Create a container with the latest Docker image and get"

build:
	docker buildx build -f ./Dockerfile \
		--progress plain \
		-t $(REPO):$(TAG) \
		--build-arg GCC_VER=$(GCC) .

buildnc:
	docker buildx build --no-cache -f ./Dockerfile \
		-t $(REPO):$(TAG) \
		--build-arg GCC_VER=$(GCC) .

build-deps:
	docker buildx build --no-cache -f ./Dockerfile.deps \
		--progress plain \
		-t $(REPO):$(ARCH)-deps .

shell:
	docker run -it --rm --name $(NAME) $(VOLUMES) $(WORKSPACE) $(REPO):$(TAG) /bin/bash

# test:
# 	snyk test --docker $(REPO):$(TAG) --file=Dockerfile
