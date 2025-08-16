#!/usr/bin/bash

cd /opt/adtools

git config --global advice.detachedHead false
git config --global user.email "walkero@gmail.com"
git config --global user.name "Georgios Sokianos"
git submodule init && \
	git submodule update && \
	gild/bin/gild checkout binutils 2.40 && \
	gild/bin/gild checkout gcc $GCC_VER

\cp /opt/misc/native-build/makefile /opt/adtools/native-build/makefile
\cp /opt/misc/texi2pod.pl /opt/adtools/binutils/repo/etc/

# Compile gcc
echo "-------- START GCC COMPILATION"
make -C native-build gcc-cross CROSS_PREFIX=/opt/ppc-amigaos BINUTILS_VERSION=2.40 -j$(nproc)
