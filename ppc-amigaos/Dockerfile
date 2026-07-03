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

# Copy necessary repos from walkero/amigagccondocker:deps
COPY --from=walkero/amigagccondocker:deps /repos/adtools /opt/adtools
COPY --from=walkero/amigagccondocker:deps /repos/binutils-gdb /opt/adtools/binutils/repo
COPY --from=walkero/amigagccondocker:deps /repos/coreutils /opt/adtools/coreutils/repo
COPY --from=walkero/amigagccondocker:deps /repos/gnulib /opt/adtools/gnulib/repo
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
LABEL maintainer="Georgios Sokianos <walkero@gmail.com>" \
      org.opencontainers.image.title="PPC AmigaOS cross-compiler base image" \
      org.opencontainers.image.description="Development image containing the ppc-amigaos SDK, compiler tools, and necessary clibs" \
      org.opencontainers.image.source="https://github.com/walkero-gr/AmigaGCConDocker-base" \
      org.opencontainers.image.url="https://github.com/walkero-gr/AmigaGCConDocker-base" \
      org.opencontainers.image.vendor="walkero" \
      org.opencontainers.image.base.name="ubuntu:latest"

COPY --from=builder /opt/ppc-amigaos /opt/ppc-amigaos
