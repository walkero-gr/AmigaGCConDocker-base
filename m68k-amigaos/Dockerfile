FROM ubuntu:latest AS builder

ARG DEBIAN_FRONTEND=noninteractive
ARG GCC_VER

ENV GCC_VER=${GCC_VER}

COPY --from=walkero/lha-on-docker /usr/bin/lha /usr/bin/lha

ENV PACKAGES="\
    autoconf \
    automake \
    autopoint \
    bison \
    ca-certificates \
    curl \
    dh-autoreconf \
    flex \
    g++-12 \
    gettext \
    git \
    gperf \
    gpg \
    libfl2 \
    libgmp-dev \
    libmpc3 \
    libmpc-dev \
    libmpfr-dev \
    libreadline-dev \
    libtool \
    make \
    mc \
    nano \
    ncurses-dev \
    patch \
    python3 \
    rsync \
    texinfo \
    wget \
    xz-utils"

ENV CC=/usr/bin/gcc
ENV CXX=/usr/bin/g++

RUN apt-get update && \
    apt-get -y --no-install-recommends install ${PACKAGES};

# Copy necessary repos from walkero/amigagccondocker:m68k-amigaos-deps
COPY --from=walkero/amigagccondocker:m68k-amigaos-deps /repos/amiga-gcc /opt/amiga-gcc
COPY scripts/setup.sh /setup.sh
COPY misc/Makefile /opt/amiga-gcc/

RUN ln -sf /usr/bin/gcc-12 /usr/bin/gcc && \
    ln -sf /usr/bin/g++-12 /usr/bin/g++ && \
    chmod +x /setup.sh && bash /setup.sh

##############################################################################
# Final Base environment image
FROM ubuntu:latest
LABEL maintainer="Georgios Sokianos <walkero@gmail.com>" \
      org.opencontainers.image.title="m68k AmigaOS cross-compiler base image" \
      org.opencontainers.image.description="Development image containing the m68k-amigaos SDK, compiler tools, and necessary clibs" \
      org.opencontainers.image.source="https://github.com/walkero-gr/AmigaGCConDocker-base" \
      org.opencontainers.image.url="https://github.com/walkero-gr/AmigaGCConDocker-base" \
      org.opencontainers.image.vendor="walkero" \
      org.opencontainers.image.base.name="ubuntu:latest"

COPY --from=builder /opt/m68k-amigaos /opt/m68k-amigaos
