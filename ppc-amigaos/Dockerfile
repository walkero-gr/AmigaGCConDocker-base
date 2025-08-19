
FROM bitnami/git:2.50.1 AS git-clone

RUN mkdir /repos; \
    git clone https://github.com/AmigaLabs/adtools.git  /repos/adtools --depth 1; \
    git clone https://github.com/bminor/binutils-gdb    /repos/binutils-gdb; \
    git clone https://github.com/coreutils/coreutils    /repos/coreutils; \
    git clone https://github.com/coreutils/gnulib       /repos/gnulib


##############################################################################
# The ubuntu:latest tag points to the "latest LTS", since that's the version recommended for general use.
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
    libtool \
    make \
    mc \
    nano \
    patch \
    python3 \
    rsync \
    wget \
    xz-utils"

RUN apt-get update && \
    apt-get -y --no-install-recommends install ${PACKAGES};

# Copy necessary repos from git-clone
COPY --from=git-clone /repos/adtools /opt/adtools
COPY --from=git-clone /repos/binutils-gdb /opt/adtools/binutils/repo
COPY --from=git-clone /repos/coreutils /opt/adtools/coreutils/repo
COPY --from=git-clone /repos/gnulib /opt/adtools/gnulib/repo
COPY misc /opt/misc
COPY scripts/compile-adtools.sh /compile-adtools.sh
COPY scripts/compile-texinfo.sh /compile-texinfo.sh

RUN ln -sf /usr/bin/gcc-12 /usr/bin/gcc && \
    ln -sf /usr/bin/g++-12 /usr/bin/g++ && \
    chmod +x /compile-texinfo.sh && bash /compile-texinfo.sh && \
    chmod +x /compile-adtools.sh && bash /compile-adtools.sh

##############################################################################
# Final Base environment image
FROM ubuntu:latest
LABEL maintainer="Georgios Sokianos <walkero@gmail.com>"

COPY --from=builder /opt/ppc-amigaos /opt/ppc-amigaos
