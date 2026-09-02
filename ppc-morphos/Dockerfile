FROM ubuntu:latest AS builder

ARG DEBIAN_FRONTEND=noninteractive
ARG GCC_VER

ENV GCC_VER=${GCC_VER} \
    CC=gcc-12 \
    CXX=g++-12 \
    PATH="/gg/bin:$PATH" 

ENV PACKAGES="\
    autoconf \
    automake \
    autopoint \
    bison \
    bmake \
    bzip2 \
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

# Copy necessary repos from walkero/amigagccondocker:ppc-morphos-deps
COPY --from=walkero/amigagccondocker:ppc-morphos-deps /packages /packages
COPY --from=walkero/lha-on-docker /usr/bin/lha /usr/bin/lha
COPY ./scripts/setup-cross-sdk_1.12.sh /packages/setup-cross-sdk.sh
COPY ./scripts/compile-texinfo.sh /packages/compile-texinfo.sh

WORKDIR /packages
RUN ln -sf /usr/bin/gcc-12 /usr/bin/gcc && \
    ln -sf /usr/bin/g++-12 /usr/bin/g++ && \
    mkdir -p /gg/bin && \
    chmod +x ./setup-cross-sdk.sh ./compile-texinfo.sh && \
    ./compile-texinfo.sh && \
    ./setup-cross-sdk.sh --gcc${GCC_VER}


# Using the pkgsrc method (gemini://blog.nil.im/86.gmi)
#
# The following needs first to be available in the ppc-morphos-deps image
# COPY --from=walkero/amigagccondocker:ppc-morphos-deps /repos/pkgsrc /opt/pkgsrc
#
# git clone https://github.com/NetBSD/pkgsrc --depth 1
# cd /opt/pkgsrc/bootstrap/ && ./bootstrap --prefix=$HOME/pkg --make-jobs 6 --unprivileged 
# then add $HOME/pkg/sbin:$HOME/pkg/bin to your PATH
# cd pkgsrc/cross/ppc-morphos-gcc && bmake MAKE_JOBS=8 install clean-depends clean

##############################################################################
# Final Base environment image
FROM ubuntu:latest
LABEL maintainer="Georgios Sokianos <walkero@gmail.com>" \
      org.opencontainers.image.title="PPC MorphOS cross-compiler base image" \
      org.opencontainers.image.description="Development image containing the ppc-morphos SDK, compiler tools, and necessary clibs" \
      org.opencontainers.image.source="https://github.com/walkero-gr/AmigaGCConDocker-base" \
      org.opencontainers.image.url="https://github.com/walkero-gr/AmigaGCConDocker-base" \
      org.opencontainers.image.vendor="walkero" \
      org.opencontainers.image.base.name="ubuntu:latest"

COPY --from=builder /gg /gg
