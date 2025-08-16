#!/usr/bin/bash

cd /tmp

curl -fsSL "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/texinfo/texinfo-7.0.tar.gz" -o /tmp/texinfo.tar.gz && \
	tar -xzf texinfo.tar.gz && \
	cd texinfo-7.0 && \
	./configure --prefix=/usr/local && \
	make && make install