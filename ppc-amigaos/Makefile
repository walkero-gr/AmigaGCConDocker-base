# os4, os3, mos
OS?=os4
# 8,9,10,11 can be used here
GCC?=11
# adtools, afxgroup
# CLIB2_REPO?=adtools
# apt,git,release
# CLIB2_SRC?=apt
# OS4 SDK version
SDK?=54.16
REL?=1.3.0

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
# 	@echo "build-exp        - Build the experiment Docker image, with gcc11 and clib4"
	@echo "shell            - Create a container with the latest Docker image and get"
# 	@echo "                   into it"
# 	@echo "clean            - Remove the docker container, if this still exists."
# 	@echo ""
# 	@echo "Parameters that can be used with build rules:"
# 	@echo "GCC              - defines the gcc version."
# 	@echo "                   Possible values: 8 (default)/9/10/11"
# 	@echo "CLIB2_REPO       - defines the clib2 repo to be cloned and used."
# 	@echo "                   Possible values: adtools (default)/afxgroup"
# 	@echo "CLIB2_SRC        - defines the afgroup clib2 source to be used."
# 	@echo "                   Possible values: apt (default)/git/release"
# 	@echo "                   Used only when CLIB2_REPO is set to afxgroup"
# 	@echo "OS               - defines the cross-compiler target OS"
# 	@echo "                   Possible values: os4 (default)/os3/mos"
# 	@echo ""

build:
	docker buildx build -f ./Dockerfile \
		-t $(REPO):$(TAG) \
		--progress plain \
		--build-arg GCC_VER=$(GCC) .

buildnc:
	docker build --no-cache -f ./Dockerfile \
		-t $(REPO):$(TAG) \
		--progress plain \
		--build-arg GCC_VER=$(GCC) .

shell:
	docker run -it --rm --name $(NAME) $(VOLUMES) $(WORKSPACE) $(REPO):$(TAG) /bin/bash

# build:
# 	docker build -f ./Dockerfile \
# 		-t $(REPO):$(TAG) \
# 		--progress plain \
# 		--build-arg GCC_VER=$(GCC) \
# 		--build-arg CLIB2_REPO=$(CLIB2_REPO) \
# 		--build-arg CLIB2_SRC=$(CLIB2_SRC) \
# 		--build-arg SDK_VER=$(SDK) .

# buildnc:
# 	docker build --no-cache -f ./Dockerfile \
# 		-t $(REPO):$(TAG) \
# 		--progress plain \
# 		--build-arg GCC_VER=$(GCC) \
# 		--build-arg CLIB2_REPO=$(CLIB2_REPO) \
# 		--build-arg CLIB2_SRC=$(CLIB2_SRC) \
# 		--build-arg SDK_VER=$(SDK) .

# build-exp:
# 	docker build -f ./exp.Dockerfile \
# 		-t $(REPO):$(OS)-base-gcc$(GCC)-exp \
# 		--progress plain \
# 		--build-arg GCC_VER=11 .

# shell:
# 	docker run -it --rm --name $(NAME) $(VOLUMES) $(WORKSPACE) $(REPO):$(TAG) /bin/bash

# shell-exp:
# 	docker run -it --rm --name $(NAME) $(VOLUMES) $(WORKSPACE) $(REPO):$(OS)-base-gcc$(GCC)-exp /bin/bash

# push:
# 	docker push $(REPO):$(TAG)

# logs:
# 	docker logs $(NAME)

# clean:
# 	-docker rm -f $(NAME)

# test:
# 	snyk test --docker $(REPO):$(TAG) --file=Dockerfile

# release: build push
