# os4, os3, mos
OS?=os4
# 8,9,10,11 can be used here
GCC?=11
# OS4 SDK version
SDK?=54.16
REL?=1.7.0

REPO=walkero/amigagccondocker
TAG?=$(OS)-gcc$(GCC)-base-$(REL)
NAME=$(TAG)
VOLUMES?=-v "${PWD}/out":/opt/out
WORKSPACE=-w /opt/adtools

.PHONY: build buildnc build-exp shell push logs clean test release

default: help

help:
	@echo "This makefile helps on building cross-compiling gcc for AmigaOS 4 PPC"
	@echo "The available parameters can be seen below:"
	@echo ""
	@echo "build            - Build the Docker image"
	@echo "buildnc          - Build the Docker image without using caching"
	@echo "shell            - Create a container with the latest Docker image and get"

build:
	docker buildx build -f ./Dockerfile \
		-t $(REPO):$(TAG) \
		--build-arg GCC_VER=$(GCC) .

buildnc:
	docker buildx build --no-cache -f ./Dockerfile \
		-t $(REPO):$(TAG) \
		--build-arg GCC_VER=$(GCC) .

shell:
	docker run -it --rm --name $(NAME) $(VOLUMES) $(WORKSPACE) $(REPO):$(TAG) /bin/bash

# test:
# 	snyk test --docker $(REPO):$(TAG) --file=Dockerfile
