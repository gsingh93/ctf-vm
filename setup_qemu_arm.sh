#!/bin/bash

URL=http://wiki.qemu-project.org/download/

latest_qemu=$(curl --silent $URL | grep -oP "\bqemu-[0-9.]+\.tar\.bz2\b" | sort | uniq | tail -n 1)

basename=$(basename $latest_qemu .tar.bz2)
if [[ ! -d $basename ]]; then
    echo "[+] Downloading latest QEMU: $latest_qemu"
    wget -q $URL/$latest_qemu
    echo

    echo "[+] Extracting $latest_qemu"
    tar -xf $latest_qemu
    echo
else
    echo "[+] Latest QEMU is already downloaded"
fi

echo "[+] Installing QEMU dependencies"
sudo apt-get -y install g++ automake libpixman-1-dev libglib2.0-dev
echo

echo "[+] Building QEMU"
cd $basename
./configure --target-list=arm-linux-user
make -j
sudo make install
echo

echo "[+] Installing ARM libraries"
sudo apt-get -y install libc6-armhf-cross
sudo mkdir /usr/gnemul
sudo ln -s /usr/arm-linux-gnueabihf /usr/gnemul/qemu-arm
echo

echo "[+] Installing ARM toolchain"
sudo apt-get -y install gcc-arm-linux-gnueabihf
sudo apt-get -y install gdb-multiarch
echo

echo "[+] Done"
