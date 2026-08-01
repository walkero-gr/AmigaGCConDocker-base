#!/usr/bin/bash
set -e

cd /opt/amiga-gcc
mkdir /opt/m68k-amigaos

# Compile gcc and the rest of the packages
echo "-------- PULL REQUIRED PACKAGES"

attempt=1
max_attempts=5
until make update; do
  if [ "$attempt" -ge "$max_attempts" ]; then
    echo "===================================== make update failed after ${max_attempts} attempts"
    exit 1
  fi

  echo "===================================== make update failed (attempt ${attempt}/${max_attempts}), retrying..."
  attempt=$((attempt + 1))
done

echo "-------- START GCC COMPILATION"
make all NDK=3.2 PREFIX=/opt/m68k-amigaos -j$(nproc --ignore=1)
make all-sdk NDK=3.2 PREFIX=/opt/m68k-amigaos -j$(nproc --ignore=1)
