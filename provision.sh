#!/bin/bash

HOMEDIR=/home/vagrant

log() {
    echo -e "\033[32m[+] $1\033[0m"
}

package() {
    sudo apt-get -y install "$@"
}

install_() {
    toolname=$1
    shift

    cd $HOMEDIR/tools
    log "Installing $toolname"
    eval install_$toolname "$@"
    log "Installation for $toolname complete"
    cd $HOMEDIR/tools
}

install_rp() {
    wget -q https://github.com/downloads/0vercl0k/rp/rp-lin-x64
    sudo install -s rp-lin-x64 /usr/bin/rp++
    rm rp-lin-x64
}

install_binjitsu() {
    package python2.7 python2.7-dev python-pip libssl-dev
    sudo -H pip install --upgrade git+https://github.com/binjitsu/binjitsu.git
}

install_pwndbg() {
    git clone https://github.com/zachriggle/pwndbg
    cd pwndbg
    ./setup.sh
}

install_peda() {
    git clone https://github.com/longld/peda.git
    if ! grep peda ~/.gdbinit &>/dev/null; then
        echo "# source $HOMEDIR/tools/peda/peda.py" >> ~/.gdbinit
    fi
}

install_pin() {
    name=pin-2.14-71313-gcc.4.4.7-linux
    wget -q http://software.intel.com/sites/landingpage/pintool/downloads/$name.tar.gz
    tar -xf $name.tar.gz
    rm $name.tar.gz
    mv $name pin
}

install_angr() {
    package python-dev libffi-dev build-essential virtualenvwrapper
    sudo -H pip install angr --upgrade
}

install_afl() {
    package clang llvm
    wget -q http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz
    tar -xf afl-latest.tgz
    rm afl-latest.tgz
    (
        cd afl-*
        make
        (
            cd qemu_mode
            ./build_qemu_support.sh
        )
        sudo make install
    )
}

install_ropgadget() {
    git clone https://github.com/JonathanSalwan/ROPgadget
    cd ROPgadget
    sudo python setup.py install
}

install_libheap() {
    git clone https://github.com/cloudburst/libheap
    sudo cp libheap/libheap.py /usr/lib/python3.4
    echo "# python from libheap import *" >> ~/.gdbinit
}

install_xrop() {
    git clone --depth 1 https://github.com/acama/xrop.git
    cd xrop
    git submodule update --init --recursive
    make
    sudo install -s xrop /usr/bin/xrop
}

install_qemu() {
    $(dirname $1)/setup_qemu_arm.sh
}

init() {
    # Updates
    sudo apt-get -y update
    sudo apt-get -y upgrade

    package emacs
    package git
    package python3-pip
    package tmux
    package gdb gdb-multiarch
    package unzip
    package foremost
    package ipython

    # Install 32 bit libs
    sudo dpkg --add-architecture i386
    sudo apt-get update
    package libc6:i386 libncurses5:i386 libstdc++6:i386
    package libc6-dev-i386
}

# Only install if script is being executed, not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    set -e

    init

    cd $HOMEDIR
    mkdir tools

    install_ pwndbg true
    install_ peda false
    install_ binjitsu
    install_ pin
    install_ afl
    #install_ libheap true

    # Multiple ROP gadget finders
    install_ ropgadget
    install_ rp
    install_ xrop

    install_ qemu
    install_ angr
fi
