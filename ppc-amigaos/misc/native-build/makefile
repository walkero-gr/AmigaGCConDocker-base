#
# This makefile drives the native build done on a non-native system, i.e.,
# before building the native compiler, a cross compiler will be build.
# We then build the native compiler using the freshly-built cross
# compiler.
#
# The user running this script must have write access to /gcc
#
# ===
CROSS_IS_PRESENT?=0
# Optional (DEFAULT=0):
# Define CROSS_IS_PRESENT=1 if a suitable cross compiler is already
# present, in which case the cross compiler build is skipped, e.g.:
#
#  make CROSS_IS_PRESENT=1
#
# ===
CLIB2_SHA1?=1a42c693e03881f6f969c43ab36ce20d2569751d
# Optional (DEFAULT 1a42c693e03881f6f969c43ab36ce20d2569751d)
# Define CLIB2_SHA1 to be the value of the branch or commit to use for clib2
# ===
CLIB4_SHA1?=30e487d28f9b3d12fc9e4adb641aeff84050de3b
# CLIB4_SHA1?=HEAD
# Optional (DEFAULT HEAD)
# Define CLIB4_SHA1 to be the value of the branch or commit to use for clib4
#
# Note that CLIB4 is only supported for certain version of GCC, see
# the variable named "CLIB4_SUPPORT" below
# ===
SDK_VERSION?=54.25
# Optional (DEFAULT=54.25):
# Define SDK_VERSION to specify which version of the Amiga SDK is desired
SDK_LOC?=
# Optional (DEFAULT=):
# Define the path that contains the local version of the SDK to avoid
# needing to download it

ROOT_DIR=$(realpath .)
VERBOSE=@

CCRED=\033[31m
CCGREEN=\033[32m
CCYELLOW=\033[33m
CCBLUE=\033[34m
CCPINK=\033[35m
CCLBLUE=\033[36m
CCEND=\033[0m
CCBOLD=\033[1m
CCITAL=\033[3m
CCUNDR=\033[4m

# Compiler setup, utilize ccache if available
CCACHE:=$(shell which ccache)
HOST_GCC:=$(strip $(CCACHE) gcc)
HOST_GXX:=$(strip $(CCACHE) g++)

GMP_ARCHIVE=gmp-5.1.3.tar.bz2
MPFR_ARCHIVE=mpfr-3.1.6.tar.bz2
MPC_ARCHIVE=mpc-1.0.3.tar.gz

BINUTILS_VERSION=$(shell cd $(BINUTILS_SRC_DIR) 2>/dev/null && git branch --show-current)
BINUTILS_SRC_DIR=../binutils/repo

GCC_SRC_DIR=../gcc/repo
GCC_VERSION:=$(shell cat $(GCC_SRC_DIR)/gcc/BASE-VER)
GCC_DEV_PHASE:=$(shell cat ${GCC_SRC_DIR}/gcc/DEV-PHASE)

ifneq ($(GCC_DEV_PHASE),)
GCC_DEV_PHASE:= ($(GCC_DEV_PHASE))
endif

GCC_MAJOR_VERSION:=$(word 1, $(subst ., , $(GCC_VERSION)))

# Handle SDK version and mapping to necessary file URL
ifeq (54.25,$(SDK_VERSION))
SDK_URL_FILE=137
else
ifeq (54.16,$(SDK_VERSION))
SDK_URL_FILE=127
else
$(error Unexpected SDK_VERSION supplied)
endif
endif
SDK_URL=https://www.hyperion-entertainment.biz/index.php?option=com_registration&amp;view=download&amp;format=raw&amp;file=$(SDK_URL_FILE)

# Native tools
COREUTILS_SRC_DIR=../coreutils/repo
COREUTILS_VERSION=5.2.1

# Distribution version, used as middle part of a distribution archive
DIST_VERSION=$(shell date +%Y%m%d)-$(shell git rev-list --count HEAD)

# libstdc++ configures each C runtime separately and turns on
# pthread_cond_clockwait() wherever that function links, which it does for
# clib4. Under the amigaos thread model, though, __gthread_cond_t and
# __gthread_mutex_t are native objects rather than pthread ones, so handing
# them to a pthread entry point misreads them. Presetting the cache variable
# answers the probe, leaving condition_variable on __gthread_cond_timedwait().
export glibcxx_cv_PTHREAD_COND_CLOCKWAIT=no

# Set up the necessary variables for the CLIBs
CLIB4_SUPPORT=$(filter 15 13 11 8 6,$(GCC_MAJOR_VERSION))
CLIB4_URL=https://github.com/AmigaLabs/clib4
CLIB4_DIR=downloads/clib4/
CLIB4_RELEASE_ARCHIVE_NAME=adtools-os4-clib4-$(DIST_VERSION).lha

CLIB2_URL=https://github.com/sodero/clib2
CLIB2_DIR=downloads/clib2/library/
CLIB2_RELEASE_ARCHIVE_NAME=adtools-os4-clib2-$(DIST_VERSION).lha

CROSS_PREFIX?=$(ROOT_DIR)/root-cross
# This assumes that cross prefix is absolute
DESTDIR?=

SPE_FLAG=
ifeq ($(GCC_MAJOR_VERSION),6)
SPE_FLAG=SPE=yes
endif

STRIPFLAGS=--strip-all --strip-unneeded-rel-relocs -R.comment

.PHONY: all
all: gcc-native-done-$(GCC_VERSION)

#
# Print the dist version that is used as suffix for various
# suffixes.
#
.PHONY: print-dist-version
print-dist-version:
	$(VERBOSE)echo $(DIST_VERSION)

#
# Downloads clib2
#
.PHONY: downloads-done-clib2
downloads-done-clib2:
	$(VERBOSE)echo "${CCPINK}${CCBOLD}\n---> Download clib2 ${CCEND}";
	$(VERBOSE)mkdir -p downloads
	$(VERBOSE)cd downloads && \
		(git clone $(CLIB2_URL) clib2 || true) && \
		cd clib2 && \
		git checkout $(CLIB2_SHA1)
	$(VERBOSE)touch $@

#
# Downloads clib4
#
ifneq ($(CLIB4_SUPPORT),)
.PHONY: downloads-done-clib4
downloads-done-clib4:
	$(VERBOSE)echo "${CCPINK}${CCBOLD}\n---> Download clib4 ${CCEND}";
	$(VERBOSE)mkdir -p downloads
	$(VERBOSE)cd downloads && \
		(git clone $(CLIB4_URL) clib4 || true) && \
		cd clib4 && \
		git checkout $(CLIB4_SHA1)
	$(VERBOSE)touch $@
endif

#
# Downloads the SDK and libraries necessary to build the cross compiler
#
DOWNLOADS_DONE_DEPENDENCY=downloads-done-clib2
ifneq ($(CLIB4_SUPPORT),)
DOWNLOADS_DONE_DEPENDENCY+=downloads-done-clib4
endif
.PHONY: downloads-done
downloads-done: $(DOWNLOADS_DONE_DEPENDENCY)
ifneq ($(SDK_LOC),)
	$(VERBOSE)cp $(SDK_LOC)/SDK_$(SDK_VERSION).lha downloads/
else
	$(VERBOSE)echo "${CCPINK}${CCBOLD}\n---> Download OS4 SDK ${CCEND}";
	$(VERBOSE)curl --retry 5 --retry-delay 2 --retry-connrefused -fsSL "$(SDK_URL)" -o ./downloads/SDK_$(SDK_VERSION).lha
endif
	$(VERBOSE)echo "${CCPINK}${CCBOLD}\n---> Download gmp ${CCEND}";
	$(VERBOSE)curl --retry 5 --retry-delay 2 --retry-connrefused -fsSL https://ftp.gnu.org/gnu/gmp/$(GMP_ARCHIVE) -o ./downloads/$(GMP_ARCHIVE)
	$(VERBOSE)echo "${CCPINK}${CCBOLD}\n---> Download mpfr ${CCEND}";
	$(VERBOSE)curl --retry 5 --retry-delay 2 --retry-connrefused -fsSL https://ftp.gnu.org/gnu/mpfr/$(MPFR_ARCHIVE) -o ./downloads/$(MPFR_ARCHIVE)
	$(VERBOSE)echo "${CCPINK}${CCBOLD}\n---> Download mpc ${CCEND}";
	$(VERBOSE)curl --retry 5 --retry-delay 2 --retry-connrefused -fsSL https://ftp.gnu.org/gnu/mpc/$(MPC_ARCHIVE) -o ./downloads/$(MPC_ARCHIVE)
	$(VERBOSE)touch $@

#
# Builds the cross binutils package (assembler, etc).
#
.PHONY: binutils-cross-build-done-$(BINUTILS_VERSION)
binutils-cross-build-done-$(BINUTILS_VERSION):
	$(VERBOSE)echo "${CCPINK}${CCBOLD}\n---> Build binutils cross $(BINUTILS_VERSION) ${CCEND}";
	$(VERBOSE)$(MAKE) -C ../binutils-build cross \
		BINUTILS_VERSION=$(BINUTILS_VERSION) \
		SRC_DIR=$(BINUTILS_SRC_DIR) \
		PREFIX=$(CROSS_PREFIX) \
		VERSION=$(BINUTILS_VERSION) \
		CROSS_BUILD_DIR=$(ROOT_DIR)/binutils-cross-build-$(BINUTILS_VERSION) > $(ROOT_DIR)/../logs/$@.log 2>&1
	$(VERBOSE)touch $@

.PHONY: binutils-build
binutils-build: binutils-cross-build-done-$(BINUTILS_VERSION)

#
# Installs the cross binutils package (assembler, etc).
#
binutils-cross-done-$(BINUTILS_VERSION): binutils-cross-build-done-$(BINUTILS_VERSION)
	$(VERBOSE)echo "${CCPINK}${CCBOLD}\n---> Install binutils cross $(BINUTILS_VERSION) ${CCEND}";
	$(VERBOSE)$(MAKE) -C $(ROOT_DIR)/binutils-cross-build-$(BINUTILS_VERSION) install DESTDIR=$(DESTDIR) > $(ROOT_DIR)/../logs/$@.log 2>&1
	$(VERBOSE)touch $@

.PHONY: binutils-install
binutils-install: binutils-cross-done-$(BINUTILS_VERSION)

#
# Prepares the includes
#
includes-done: downloads-done
	$(VERBOSE)echo "${CCPINK}${CCBOLD}\n---> Prepare the SDK and header files ${CCEND}";
	$(VERBOSE)mkdir -p $(CROSS_PREFIX)/ppc-amigaos/SDK/include
	$(VERBOSE)cd downloads && lha -xfq2 SDK_$(SDK_VERSION).lha
	$(VERBOSE)cd downloads/SDK_Install && lha -xfq2 newlib*.lha
	$(VERBOSE)cd downloads/SDK_Install && lha -xfq2 base.lha
	$(VERBOSE)cd downloads/SDK_Install && lha -xfq2 execsg*.lha
	$(VERBOSE)cd downloads/SDK_Install && rm -rf *.lha
	$(VERBOSE)rm -rf $(CROSS_PREFIX)/ppc-amigaos/SDK/newlib && \
		cd downloads/SDK_Install && mv newlib* $(CROSS_PREFIX)/ppc-amigaos/SDK
	$(VERBOSE)rm -rf $(CROSS_PREFIX)/ppc-amigaos/SDK/include/* && \
		cd downloads/SDK_Install && mv Include/* $(CROSS_PREFIX)/ppc-amigaos/SDK/include
	$(VERBOSE)rm -rf downloads/SDK_Install downloads/SDK_Install.info
	$(VERBOSE)touch $@

#
# Path to the initial cross compiler or standard
# cross compiler if a cross compiler is present
#

ifeq ($(CROSS_IS_PRESENT),1)

XGCC=ppc-amigaos-gcc
XGCC_CC=ppc-amigaos-gcc
XAR=ppc-amigaos-ar -q
XRANLIB=ppc-amigaos-ranlib
STRIP=ppc-amigaos-strip

CLIB_CROSS_DONE_DEPENDENCY=downloads-done-clib2
ifneq ($(CLIB4_SUPPORT),)
CLIB_CROSS_DONE_DEPENDENCY+=downloads-done-clib4
endif

else

XGCC_DIR=$(abspath .)/gcc-cross-build-$(GCC_VERSION)/gcc
XGCC=$(XGCC_DIR)/xgcc
XGCC_CC=$(XGCC) -B $(XGCC_DIR)
XAR=$(CROSS_PREFIX)/bin/ppc-amigaos-ar -q
XRANLIB=$(CROSS_PREFIX)/bin/ppc-amigaos-ranlib
STRIP=$(CROSS_PREFIX)/bin/ppc-amigaos-strip

CLIB_CROSS_DONE_DEPENDENCY=xgcc-done-$(GCC_VERSION)

endif

#
# Prints the folder where the basic xg (xgcc or xg++) compilers
# can be round.
#
.PHONY: print-xg-dir
print-xg-dir:
	$(VERBOSE)echo $(XGCC_DIR)

#
# Build only xgcc, no other stuff like libstdc++ etc.
#
xgcc-done-$(GCC_VERSION): includes-done binutils-cross-done-$(BINUTILS_VERSION)
	$(VERBOSE)echo "${CCPINK}${CCBOLD}\n---> Build xgcc cross compiler ${CCEND}";
	$(VERBOSE)CC="$(HOST_GCC)" CXX="$(HOST_GXX)" $(MAKE) -C ../gcc-build cross-configure \
		SRC_DIR=$(GCC_SRC_DIR) \
		PREFIX=$(CROSS_PREFIX) \
		CROSS_BUILD_DIR=$(ROOT_DIR)/gcc-cross-build-$(GCC_VERSION) \
		VERSION=$(GCC_VERSION) > $(ROOT_DIR)/../logs/$@_configure.log 2>&1
	$(VERBOSE)$(MAKE) -C $(ROOT_DIR)/gcc-cross-build-$(GCC_VERSION) all-gcc > $(ROOT_DIR)/../logs/$@_build.log 2>&1
	$(VERBOSE)touch $@

#
# Build clib via xgcc
#
ifneq ($(CLIB4_SUPPORT),)
clib4-cross-done-$(GCC_VERSION): $(CLIB_CROSS_DONE_DEPENDENCY) includes-done
	$(VERBOSE)echo "${CCPINK}${CCBOLD}\n---> Build clib4 library ${CCEND}";
# Build clib using xgcc that have just been built
	$(VERBOSE)$(MAKE) -C $(CLIB4_DIR) -f GNUmakefile.os4 \
		CC="$(XGCC_CC)" \
		AR="$(XAR)" \
		RANLIB="$(XRANLIB)" \
		STRIP=$(STRIP) \
		$(SPE_FLAG) \
		INSTALL_PREFIX=$(CROSS_PREFIX)/ppc-amigaos/SDK/clib4 \
		SDK_INCLUDE=$(CROSS_PREFIX)/ppc-amigaos/SDK/include > $(ROOT_DIR)/../logs/$@_build.log 2>&1
# Copy clib libs and includes
	$(VERBOSE)$(MAKE) -C $(CLIB4_DIR) -f GNUmakefile.os4 install \
		$(SPE_FLAG) \
		INSTALL_PREFIX=$(CROSS_PREFIX)/ppc-amigaos/SDK/clib4 > $(ROOT_DIR)/../logs/$@_install.log 2>&1
	$(VERBOSE)cp $(CLIB4_DIR)/LICENSE* $(CROSS_PREFIX)/ppc-amigaos/SDK/clib4
	$(VERBOSE)touch $@
endif

clib2-cross-done-$(GCC_VERSION): $(CLIB_CROSS_DONE_DEPENDENCY)
	$(VERBOSE)echo "${CCPINK}${CCBOLD}\n---> Build clib2 library ${CCEND}";
# Build clib using xgcc that have just been built
	$(VERBOSE)$(MAKE) -C $(CLIB2_DIR) -f GNUmakefile.os4 \
		CC="$(XGCC_CC) -Wno-error=int-conversion -Wno-error=incompatible-pointer-types -Wno-error=implicit-function-declaration" \
		AR="$(XAR)" \
		RANLIB="$(XRANLIB)" > $(ROOT_DIR)/../logs/$@_build.log 2>&1
# Copy clib libs and includes
	$(VERBOSE)rm -Rf $(CROSS_PREFIX)/ppc-amigaos/SDK/clib2/lib $(CROSS_PREFIX)/ppc-amigaos/SDK/clib2/include
	$(VERBOSE)mkdir -p $(CROSS_PREFIX)/ppc-amigaos/SDK/clib2/lib
	$(VERBOSE)mkdir -p $(CROSS_PREFIX)/ppc-amigaos/SDK/clib2/include
	$(VERBOSE)cp -Rp $(CLIB2_DIR)/include/* $(CROSS_PREFIX)/ppc-amigaos/SDK/clib2/include
	$(VERBOSE)cp -Rp $(CLIB2_DIR)/lib/* $(CROSS_PREFIX)/ppc-amigaos/SDK/clib2/lib
	$(VERBOSE)cp $(CLIB2_DIR)/../LICENSE $(CROSS_PREFIX)/ppc-amigaos/SDK/clib2
	$(VERBOSE)touch $@

#
# Build the cross compiler
#
GCC_CROSS_DONE_DEPENDENCY=clib2-cross-done-$(GCC_VERSION)
ifneq ($(CLIB4_SUPPORT),)
GCC_CROSS_DONE_DEPENDENCY+=clib4-cross-done-$(GCC_VERSION)
endif
gcc-cross-done-$(GCC_VERSION): $(GCC_CROSS_DONE_DEPENDENCY)
	$(VERBOSE)echo "${CCPINK}${CCBOLD}\n---> Done building GCC cross compiler ${CCEND}";
# Compile remaining
	$(VERBOSE)$(MAKE) -C $(ROOT_DIR)/gcc-cross-build-$(GCC_VERSION) > $(ROOT_DIR)/../logs/$@_build.log 2>&1
	$(VERBOSE)$(MAKE) -C $(ROOT_DIR)/gcc-cross-build-$(GCC_VERSION) install > $(ROOT_DIR)/../logs/$@_install.log 2>&1
	$(VERBOSE)touch $@

.PHONY: gcc-cross
gcc-cross: gcc-cross-done-$(GCC_VERSION)

#
# Optional target for additional libs
#
.PHONY: additionals-libs
additionals-libs:
	$(VERBOSE)echo "${CCPINK}${CCBOLD}\n---> Install additional libs ${CCEND}";
	$(VERBOSE)mkdir -p $(CROSS_PREFIX)/ppc-amigaos/SDK/local/common/include
	$(VERBOSE)mkdir -p /tmp/abcd
	$(VERBOSE)cd downloads && lha xw=/tmp/abcd SDK_$(SDK_VERSION).lha
	$(VERBOSE)cd /tmp/abcd/SDK_Install && lha x pthread.lha && lha x zlib-1.2.3.lha
	$(VERBOSE)cp -Rf /tmp/abcd/SDK_Install/Local/* $(CROSS_PREFIX)/ppc-amigaos/SDK/local
	$(VERBOSE)rm -Rf /tmp/abcd


ifeq ($(CROSS_IS_PRESENT),1)
NATIVE_LIBRARY_DEPENDENCIES=downloads-done
else
NATIVE_LIBRARY_DEPENDENCIES=gcc-cross-done-$(GCC_VERSION)
endif

#
# Build and install the libraries
#
libraries-done: $(NATIVE_LIBRARY_DEPENDENCIES)
	$(VERBOSE)echo "${CCPINK}${CCBOLD}\n---> Build and install the gmp, mpfr, and mpc libraries ${CCEND}";
	$(VERBOSE)cd downloads && tar -xjf $(notdir $(GMP_ARCHIVE))
	$(VERBOSE)cd downloads && tar -xjf $(notdir $(MPFR_ARCHIVE))
	$(VERBOSE)cd downloads && tar -xzf $(notdir $(MPC_ARCHIVE))
	$(VERBOSE)cd $(basename $(basename downloads/$(notdir $(GMP_ARCHIVE)))) && \
		PATH="$(CROSS_PREFIX)/bin:$(PATH)" CFLAGS="-O2 -std=gnu89" ./configure --host=ppc-amigaos --prefix=$(CROSS_PREFIX) && \
		PATH="$(CROSS_PREFIX)/bin:$(PATH)" make install > $(ROOT_DIR)/../logs/$@_gmp_build.log 2>&1
	$(VERBOSE)cd $(basename $(basename downloads/$(notdir $(MPFR_ARCHIVE)))) && \
		PATH="$(CROSS_PREFIX)/bin:$(PATH)" ./configure --host=ppc-amigaos --prefix=$(CROSS_PREFIX) -with-gmp=$(CROSS_PREFIX) && \
		PATH="$(CROSS_PREFIX)/bin:$(PATH)" make install > $(ROOT_DIR)/../logs/$@_mpfr_build.log 2>&1
	$(VERBOSE)cd $(basename $(basename downloads/$(notdir $(MPC_ARCHIVE)))) && \
		PATH="$(CROSS_PREFIX)/bin:$(PATH)" ./configure --host=ppc-amigaos --prefix=$(CROSS_PREFIX) --with-gmp=$(CROSS_PREFIX) --with-mpfr=$(CROSS_PREFIX) && \
		PATH="$(CROSS_PREFIX)/bin:$(PATH)" make install > $(ROOT_DIR)/../logs/$@_mpc_build.log 2>&1
	$(VERBOSE)touch $@

#
# Build the native binutils
#
binutils-native-done-$(BINUTILS_VERSION): libraries-done
	$(VERBOSE)echo "${CCPINK}${CCBOLD}\n---> Build the native binutils ${CCEND}";
	$(VERBOSE)PATH="$(CROSS_PREFIX)/bin:$(PATH)" $(MAKE) -C ../binutils-build native \
		BINUTILS_VERSION=$(BINUTILS_VERSION) \
		SRC_DIR=$(BINUTILS_SRC_DIR) \
		PREFIX=/gcc \
		VERSION=$(BINUTILS_VERSION) \
		NATIVE_BUILD_DIR=$(ROOT_DIR)/binutils-native-build-$(BINUTILS_VERSION) > $(ROOT_DIR)/../logs/$@.log 2>&1
	$(VERBOSE)touch $@

#
# Build the native gcc
#
gcc-native-done-$(GCC_VERSION): binutils-native-done-$(BINUTILS_VERSION)
	$(VERBOSE)echo "${CCPINK}${CCBOLD}\n---> Build the native gcc $(GCC_VERSION) ${CCEND}";
	$(VERBOSE)mkdir -p $(ROOT_DIR)/root-native/gcc/include
	$(VERBOSE)mkdir -p /gcc/include
	$(VERBOSE)PATH="$(CROSS_PREFIX)/bin:$(PATH)" $(MAKE) -C ../gcc-build native \
		SRC_DIR=$(GCC_SRC_DIR) \
		PREFIX=/gcc \
		NATIVE_BUILD_DIR=$(ROOT_DIR)/gcc-native-build-$(GCC_VERSION) \
		VERSION=$(GCC_VERSION) \
		LIB_PATH=$(CROSS_PREFIX) \
		NATIVE_SYS_ROOT=$(ROOT_DIR)/root-native > $(ROOT_DIR)/../logs/$@.log 2>&1
	$(VERBOSE)touch $@

ifeq ($(CROSS_IS_PRESENT),1)
coreutils-native-done:
else

coreutils-native-done: gcc-cross-done-$(GCC_VERSION)
endif
	$(VERBOSE)echo "${CCPINK}${CCBOLD}\n---> Install coreutils native ${CCEND}";
	$(VERBOSE)mkdir -p coreutils-native-build
	$(VERBOSE)@if [ ! -f $(COREUTILS_SRC_DIR)/configure ]; then echo "Please checkout coreutils first!"; false; fi
# Pretend few files to be uptodate
	$(VERBOSE)touch $(realpath $(COREUTILS_SRC_DIR))/configure $(realpath $(COREUTILS_SRC_DIR))/config.hin
	$(VERBOSE)cd coreutils-native-build ; \
		$(realpath $(COREUTILS_SRC_DIR))/configure --prefix=/gcc --host=ppc-amigaos --disable-maintainer-mode \
		PATH="$(CROSS_PREFIX)/bin:$(PATH)" \
		CFLAGS="-g -O2 -std=gnu17" \
		CPPFLAGS="-mcrt=clib2" \
		LDFLAGS="-mcrt=clib2" \
		LIBS="-lunix -lnet"
	$(VERBOSE)PATH="$(CROSS_PREFIX)/bin:$(PATH)" $(MAKE) -C coreutils-native-build > $(ROOT_DIR)/../logs/$@.log 2>&1
	$(VERBOSE)touch $@


GCC_BASE_BRANCH_NAME=$(GCC_MAJOR_VERSION)-base
#
# Build the main docs
#
.PHONY: doc
doc:
	$(VERBOSE)rm -Rf $@
	$(VERBOSE)mkdir -p $@/tmp/orig
	$(VERBOSE)mkdir -p $@/tmp/patched

	$(VERBOSE)echo "@set version-GCC $(GCC_VERSION)-adtools" >$@/tmp/orig/gcc-vers.texi
	$(VERBOSE)echo "@set srcdir $(ROOT_DIR)/$(GCC_BASE_BRANCH_NAME)/gcc" >>$@/tmp/orig/gcc-vers.texi
	$(VERBOSE)echo "@set BUGURL https://github.com/sba1/adtools/issues" >>$@/tmp/orig/gcc-vers.texi

	$(VERBOSE)echo "@set version-GCC $(GCC_VERSION)-adtools" >$@/tmp/patched/gcc-vers.texi
	$(VERBOSE)echo "@set srcdir $(GCC_SRC_DIR)/gcc" >>$@/tmp/patched/gcc-vers.texi
	$(VERBOSE)echo "@set BUGURL https://github.com/sba1/adtools/issues" >>$@/tmp/patched/gcc-vers.texi

	# Checkout base branch as worktree
	$(VERBOSE)cd $(GCC_SRC_DIR) && git worktree add -f $(ROOT_DIR)/$(GCC_BASE_BRANCH_NAME) $(GCC_BASE_BRANCH_NAME) || true
	$(VERBOSE)cd $(ROOT_DIR)/$(GCC_BASE_BRANCH_NAME) && git checkout --detach $(GCC_BASE_BRANCH_NAME)

	$(VERBOSE)makeinfo --plaintext -I $(GCC_BASE_BRANCH_NAME)/gcc/doc -I $(GCC_BASE_BRANCH_NAME)/gcc/doc/include -I $@/tmp/orig -o $@/tmp/orig/gcc.txt $(GCC_BASE_BRANCH_NAME)/gcc/doc/gcc.texi
	$(VERBOSE)makeinfo --plaintext -I $(GCC_BASE_BRANCH_NAME)/gcc/doc -I $(GCC_BASE_BRANCH_NAME)/gcc/doc/include -I $@/tmp/orig -o $@/tmp/orig/cpp.txt $(GCC_BASE_BRANCH_NAME)/gcc/doc/cpp.texi

	$(VERBOSE)makeinfo --plaintext -I $(GCC_SRC_DIR)/gcc/doc -I $(GCC_SRC_DIR)/gcc/doc/include -I $@/tmp/patched -o $@/tmp/patched/gcc.txt $(GCC_SRC_DIR)/gcc/doc/gcc.texi
	$(VERBOSE)makeinfo --plaintext -I $(GCC_SRC_DIR)/gcc/doc -I $(GCC_SRC_DIR)/gcc/doc/include -I $@/tmp/patched -o $@/tmp/patched/cpp.txt $(GCC_SRC_DIR)/gcc/doc/cpp.texi

	$(VERBOSE)cd $@/tmp && bash -c "wdiff -n -w $$'\033[30;41m' -x $$'\033[0m' -y $$'\033[30;42m' -z $$'\033[0m' orig/gcc.txt patched/gcc.txt >../gcc.txt" || true
	$(VERBOSE)cd $@/tmp && bash -c "wdiff -n -w $$'\033[30;41m' -x $$'\033[0m' -y $$'\033[30;42m' -z $$'\033[0m' orig/cpp.txt patched/cpp.txt >../cpp.txt" || true

	$(VERBOSE)rm -Rf $@/tmp
#
# Target for generating the ReadMe used for Aminet
#
ifneq ($(CLIB4_SUPPORT),)
CLIB4_ENTRY=CLIB4_RELEASE_ARCHIVE_NAME='$(CLIB4_RELEASE_ARCHIVE_NAME)'
else
CLIB4_ENTRY=CLIB4_RELEASE_ARCHIVE_NAME='<NOT GENERATED>'
endif
ReadMe: ReadMe.mak
	$(VERBOSE)python -c "\
	from mako.template import Template;\
	from mako.lookup import TemplateLookup;\
	print (Template(\
		filename='$<',\
		input_encoding='utf-8',\
		output_encoding='utf-8',\
		lookup=TemplateLookup(['./'],input_encoding='utf-8')).render(\
			DIST_VERSION='$(DIST_VERSION)',\
			ADTOOLS_COMMIT_SHA1='$(shell git rev-list HEAD -1)',\
			BINUTILS_VERSION='$(BINUTILS_VERSION)',\
			GCC_VERSION='$(GCC_VERSION)',\
			GCC_DEV_PHASE='$(GCC_DEV_PHASE)',\
			COREUTILS_VERSION='$(COREUTILS_VERSION)',\
			CLIB2_RELEASE_ARCHIVE_NAME='$(CLIB2_RELEASE_ARCHIVE_NAME)',\
			$(CLIB4_ENTRY)\
		))\
	" >$@.utf8
	$(VERBOSE)iconv --from-code=UTF8 --to-code=ISO-8859-15 $@.utf8 >$@

# Function to make a file whose name is prefixed by the target alias
# but which is the same as the given one.
#
# We use cp here until we know that softlinks would work properly.
define MAKE_TARGET_ALIAS
	cp /gcc/bin/$(1) /gcc/bin/ppc-amigaos-$(1)
endef

# A simple macro for inserting a newline
define NL


endef

#
# Lists all executable files that are produced by the binutils steps
# and that also should be reachable via a target alias prefix.
#
BINUTILS_EXES = \
	addr2line \
	ar \
	as \
	c++filt \
	elfedit \
	gprof \
	ld \
	ld.bfd \
	nm \
	objcopy \
	objdump \
	ranlib \
	readelf \
	size \
	strings \
	strip

#
# Install native compiler into /gcc. Needs write access to this directory
#
native-install: coreutils-native-done gcc-native-done-$(GCC_VERSION) ReadMe doc
	$(VERBOSE)rm -Rf /gcc/*
	$(VERBOSE)PATH="$(CROSS_PREFIX)/bin:$(PATH)" $(MAKE) -C binutils-native-build-$(BINUTILS_VERSION) install
# Create copies of few files that usually are also accessible via a filename with the target alias prefix
	$(VERBOSE)$(foreach EXE, $(BINUTILS_EXES), $(call MAKE_TARGET_ALIAS,$(EXE))$(NL))
	$(VERBOSE)PATH="$(CROSS_PREFIX)/bin:$(PATH)" $(MAKE) -C gcc-native-build-$(GCC_VERSION) install
	$(VERBOSE)PATH="$(CROSS_PREFIX)/bin:$(PATH)" $(MAKE) -C coreutils-native-build install
# Disabled SDK as we don't want to distribute it
#	cp -R $(CROSS_PREFIX)/ppc-amigaos/SDK /gcc
# Disabled, because we don't want to copy from CROSS_PREFIX here
#	cp -Rf $(CROSS_PREFIX)/lib/gcc/ppc-amigaos /gcc/lib/gcc/
# Delete all but our target gcc libs
	$(VERBOSE)find /gcc/lib/gcc/ppc-amigaos -mindepth 1 -maxdepth 1 -not -name $(GCC_VERSION) | xargs rm -Rf
# Disabled, no longer required
#	# Move lib archives (e.g., libgcc.a into the proper directory)
#	cd /gcc/lib/gcc ; for lib in `find -name *.a -o -name *.so`; do mkdir -p `dirname $$lib`/lib; mv $$lib `dirname $$lib`/lib ; done
	$(VERBOSE)cp ReadMe /gcc
	$(VERBOSE)mkdir -p /gcc/doc
	$(VERBOSE)cp doc/* /gcc/doc

#
# Similar to native-install but deploys the components in separate directories
#
native-separate-install:
	$(VERBOSE)rm -Rf root-native-binutils
	$(VERBOSE)rm -Rf root-native-gcc
	$(VERBOSE)rm -Rf root-native-coreutils
	$(VERBOSE)PATH="$(CROSS_PREFIX)/bin:$(PATH)" $(MAKE) -C binutils-native-build-$(BINUTILS_VERSION) install DESTDIR=$(ROOT_DIR)/root-native-binutils
	$(VERBOSE)PATH="$(CROSS_PREFIX)/bin:$(PATH)" $(MAKE) -C gcc-native-build-$(GCC_VERSION) install DESTDIR=$(ROOT_DIR)/root-native-gcc
	$(VERBOSE)PATH="$(CROSS_PREFIX)/bin:$(PATH)" $(MAKE) -C coreutils-native-build install DESTDIR=$(ROOT_DIR)/root-native-coreutils
	$(VERBOSE)$(MAKE) private-native-separate-dist

# Private target. Unfinished
private-native-separate-dist:
	$(VERBOSE)$(foreach var,$(wildcard $(ROOT_DIR)/root-native-coreutils/gcc/bin/*), $(STRIP) $(STRIPFLAGS) $(var) ; ) true
	$(VERBOSE)$(foreach var,$(wildcard $(ROOT_DIR)/root-native-binutils/gcc/bin/*), $(STRIP) $(STRIPFLAGS) $(var) ; ) true
	$(VERBOSE)$(foreach var,$(wildcard $(ROOT_DIR)/root-native-gcc/gcc/bin/*), $(STRIP) $(STRIPFLAGS) $(var) ; ) true
	$(VERBOSE)$(STRIP) $(STRIPFLAGS) $(ROOT_DIR)/root-native-gcc/gcc/libexec/gcc/ppc-amigaos/$(GCC_VERSION)/cc1
	$(VERBOSE)$(STRIP) $(STRIPFLAGS) $(ROOT_DIR)/root-native-gcc/gcc/libexec/gcc/ppc-amigaos/$(GCC_VERSION)/cc1plus
	$(VERBOSE)$(STRIP) $(STRIPFLAGS) $(ROOT_DIR)/root-native-gcc/gcc/libexec/gcc/ppc-amigaos/$(GCC_VERSION)/cc1obj
	$(VERBOSE)$(STRIP) $(STRIPFLAGS) $(ROOT_DIR)/root-native-gcc/gcc/libexec/gcc/ppc-amigaos/$(GCC_VERSION)/cc1objplus
	$(VERBOSE)$(STRIP) $(STRIPFLAGS) $(ROOT_DIR)/root-native-gcc/gcc/libexec/gcc/ppc-amigaos/$(GCC_VERSION)/lto1
	$(VERBOSE)$(STRIP) $(STRIPFLAGS) $(ROOT_DIR)/root-native-gcc/gcc/libexec/gcc/ppc-amigaos/$(GCC_VERSION)/lto-wrapper
	$(VERBOSE)rm -Rf dist
	$(VERBOSE)mkdir -p dist/coreutils-$(COREUTILS_VERSION)-$(DIST_VERSION)

#
# Strip native files
#
native-strip:
# Invoke make recursively with another target so that $(wildcard) is properly resolved.
	$(VERBOSE)$(MAKE) native-strip-really

native-strip-really:
	$(VERBOSE)$(foreach var,$(wildcard /gcc/bin/*), $(STRIP) --strip-all --strip-unneeded-rel-relocs $(var) ; ) true
	$(VERBOSE)$(STRIP) $(STRIPFLAGS) /gcc/libexec/gcc/ppc-amigaos/$(GCC_VERSION)/cc1
	$(VERBOSE)$(STRIP) $(STRIPFLAGS) /gcc/libexec/gcc/ppc-amigaos/$(GCC_VERSION)/cc1plus
	$(VERBOSE)$(STRIP) $(STRIPFLAGS) /gcc/libexec/gcc/ppc-amigaos/$(GCC_VERSION)/cc1obj
	$(VERBOSE)$(STRIP) $(STRIPFLAGS) /gcc/libexec/gcc/ppc-amigaos/$(GCC_VERSION)/cc1objplus
	$(VERBOSE)$(STRIP) $(STRIPFLAGS) /gcc/libexec/gcc/ppc-amigaos/$(GCC_VERSION)/lto1
	$(VERBOSE)$(STRIP) $(STRIPFLAGS) /gcc/libexec/gcc/ppc-amigaos/$(GCC_VERSION)/lto-wrapper

#
# Native distribution archive
#
DIST_FOLDER:=adtools-os4-$(GCC_MAJOR_VERSION)-$(DIST_VERSION)

native-dist: native-strip-really
	$(VERBOSE)rm -f $(realpath .)/$(DIST_FOLDER).lha
	$(VERBOSE)rm -Rf /tmp/$(DIST_FOLDER)
	$(VERBOSE)mkdir /tmp/$(DIST_FOLDER)
	$(VERBOSE)cp -pR /gcc/* /tmp/$(DIST_FOLDER)

	# Deduplicate
	$(VERBOSE)../bin/dedup /tmp/$(DIST_FOLDER) >.dedup
	$(VERBOSE)echo "; Create alternative filenames" >/tmp/$(DIST_FOLDER)/RestoreLinks
	$(VERBOSE)../bin/dedup /tmp/$(DIST_FOLDER) --amigaos --folder-is-pwd >>/tmp/$(DIST_FOLDER)/RestoreLinks
# Disbaled until we find a way to keep softlinks via lha
#	sh -x .dedup
#	rm .dedup

	$(VERBOSE)cd /tmp && lha ao5 $(realpath .)/$(DIST_FOLDER).lha $(DIST_FOLDER)/*

#
# Clib distribution
#
clib2-dist: clib2-cross-done-$(GCC_VERSION)
	$(VERBOSE)cd root-cross/ppc-amigaos/SDK && lha ao5 $(realpath .)/$(CLIB2_RELEASE_ARCHIVE_NAME) clib2
ifneq ($(CLIB4_SUPPORT),)
clib4-dist: clib4-cross-done-$(GCC_VERSION)
	$(VERBOSE)cd root-cross/ppc-amigaos/SDK && lha ao5 $(realpath .)/$(CLIB4_RELEASE_ARCHIVE_NAME) clib4
endif

#
# Upload the binary archive to the main Aminet server
#
.PHONY: upload-release
upload-release: native-dist
	$(VERBOSE)ln -s $(DIST_FOLDER).lha adtools-$(GCC_MAJOR_VERSION)-os4.lha
	$(VERBOSE)lftp -e "put adtools-$(GCC_MAJOR_VERSION)-os4.lha && put ReadMe -o adtools-$(GCC_MAJOR_VERSION)-os4.readme && quit" ftp://main.aminet.net/new

#
# Cleanup clib
#

.PHONY: clean-clib2
clean-clib2:
	$(VERBOSE)test ! -d $(CLIB2_DIR) || $(MAKE) -C $(CLIB2_DIR) -f GNUmakefile.os4 clean
.PHONY: clean-clib4
clean-clib4:
	$(VERBOSE)test ! -d $(CLIB4_DIR) || $(MAKE) -C $(CLIB4_DIR) -f GNUmakefile.os4 clean

#
# Cleanup gcc only
#

.PHONY: clean-gcc
clean-gcc:
	$(VERBOSE)rm -Rf \
		xgcc-done-$(GCC_VERSION) \
		gcc-cross-build-$(GCC_VERSION) \
		gcc-cross-done-$(GCC_VERSION) \
		gcc-native-build-$(GCC_VERSION) \
		gcc-native-done-$(GCC_VERSION)

#
# Cleanup everything
#
.PHONY: clean
clean: clean-clib2 clean-clib4 clean-gcc
	$(VERBOSE)rm -Rf	\
		binutils-cross-build-$(BINUTILS_VERSION) \
		binutils-native-build-$(BINUTILS_VERSION) \
		$(CROSS_PREFIX) \
		build-cross-done \
		binutils-cross-build-done-$(BINUTILS_VERSION) \
		binutils-cross-done-$(BINUTILS_VERSION) \
		binutils-native-done-$(BINUTILS_VERSION) \
		clib2-cross-done-$(GCC_VERSION) \
		clib4-cross-done-$(GCC_VERSION) \
		includes-done \
		libraries-done \
		root-native \
		coreutils-native-build \
		coreutils-native-done

#
# Cleanup really everything
#
.PHONY: clean-all
clean-all: clean
	$(VERBOSE)rm -Rf downloads-done downloads-done-clib2 downloads-done-clib4 downloads
