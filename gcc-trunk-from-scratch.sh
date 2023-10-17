#!/bin/bash
set -euxo pipefail

# Install dependencies that the GCC script doesn't
sudo apt update
sudo apt -y install build-essential
sudo apt -y install gcc-multilib
sudo apt -y install bison
sudo apt -y install flex
sudo apt -y install texinfo
sudo apt -y install libgmp3-dev
sudo apt -y install libmpc-dev
sudo apt -y install libmpfr-dev

mkdir gcc-trunk || true
cd gcc-trunk

# Get or navigate to binutils source
if [ -d "binutils-trunk" ]; then
    cd binutils-trunk
    git pull
else
    git clone git://sourceware.org/git/binutils-gdb.git binutils-trunk
    cd binutils-trunk
fi

export PREFIX=/usr/local/gcc-trunk

# Build binutils
mkdir build || true
cd build

if ! [ -f "Makefile" ]; then
    ../configure --prefix="$PREFIX" --disable-nls --disable-werror
fi

make -j $((`nproc` + 1))
sudo make install

cd ../.. # top-level gcc-trunk

# Get or navigate to GCC source
if [ -d "gcc-trunk" ]; then
    cd gcc-trunk
    git pull
else
    git clone git://gcc.gnu.org/git/gcc.git gcc-trunk
    cd gcc-trunk
fi

# Build GCC
contrib/download_prerequisites

mkdir build || true
cd build

if ! [ -f "Makefile" ]; then
    ../configure --prefix="$PREFIX" --disable-nls --enable-languages=c,c++
fi

make -j $((`nproc` + 1))
sudo make install

cd ../../.. # Starting directory