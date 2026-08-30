#!/usr/bin/bash

cd /opt/adtools

BINUTILS=2.40
if [ "$GCC_VER" = "6" ]; then
BINUTILS=2.23.2
fi

# \cp -R /opt/misc/gcc/* /opt/adtools/gcc/
\cp -R /opt/misc/gcc-build/* /opt/adtools/gcc-build/
# \cp -R /opt/misc/binutils-build/* /opt/adtools/binutils-build/
# rm /opt/adtools/gcc/11/patches/0043-Added-eh-frame-hdr-in-LINK_SPEC.patch

git config --global advice.detachedHead false
git config --global user.email "walkero@gmail.com"
git config --global user.name "Georgios Sokianos"
git submodule init && \
	git submodule update && \
	gild/bin/gild checkout binutils $BINUTILS && \
	gild/bin/gild checkout gcc $GCC_VER

# \cp /opt/misc/native-build/makefile /opt/adtools/native-build/makefile
# \cp /opt/misc/texi2pod.pl /opt/adtools/binutils/repo/etc/

# Temporary patches that need to be removed
# \cp -R /opt/misc/gcc11_patched/* /opt/adtools/gcc/repo/

# Compile gcc
echo "-------- START GCC COMPILATION"
make -C native-build gcc-cross CROSS_PREFIX=/opt/ppc-amigaos BINUTILS_VERSION=$BINUTILS -j$(nproc --ignore=1)
