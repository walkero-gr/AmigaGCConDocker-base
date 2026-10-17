#!/usr/bin/bash

cd /opt/adtools
mkdir ./logs

BINUTILS=2.40
if [ "$GCC_VER" = "6" ]; then
BINUTILS=2.23.2
fi

# \cp -R /opt/misc/gcc/* /opt/adtools/gcc/
# \cp -R /opt/misc/binutils-build/* /opt/adtools/binutils-build/

\cp -R /opt/misc/gcc-build/* /opt/adtools/gcc-build/
\cp /opt/misc/native-build/makefile /opt/adtools/native-build/makefile

git config --global advice.detachedHead false
git config --global user.email "walkero@gmail.com"
git config --global user.name "Georgios Sokianos"
git submodule init && \
	git submodule update && \
	gild/bin/gild checkout binutils $BINUTILS && \
	gild/bin/gild checkout gcc $GCC_VER

# Compile gcc
echo "-------- START GCC COMPILATION"
make -C native-build gcc-cross CROSS_PREFIX=/opt/ppc-amigaos BINUTILS_VERSION=$BINUTILS -j$(nproc --ignore=1)
