#!/bin/bash

# Bash strict mode
set -euo pipefail

# Verbose
#set -x

HOMEDIR=/home/vagrant

log() {
    echo -e "\033[32m[+] $1\033[0m"
}

package() {
    sudo apt-get -y install "$@"
}

git_clone() {
    # Clone git repo into directory, clearing directory if it exists
    # Usage: git_clone URL DIR [GIT_CLONE OPTIONS...]

    local url="$1"
    shift
    local dir="$1"
    shift

    sudo rm -rf "$dir"
    git clone "$@" "$url" "$dir"
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

install_pwntools() {
    package python2.7 python2.7-dev python-pip libssl-dev libffi-dev
    sudo -H pip install --upgrade pwntools
}

install_pwndbg() {
    # We echo this here because otherwise `setup.sh` will echo the wrong
    # path
    if ! grep pwndbg ~/.gdbinit &>/dev/null; then
        echo "# source $HOMEDIR/tools/pwndbg/gdbinit.py" >> ~/.gdbinit
    fi
    git_clone https://github.com/pwndbg/pwndbg.git pwndbg
    cd pwndbg
    ./setup.sh
}

install_peda() {
    git_clone https://github.com/longld/peda.git peda
    if ! grep peda ~/.gdbinit &>/dev/null; then
        echo "source $HOMEDIR/tools/peda/peda.py" >> ~/.gdbinit
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
    package clang llvm libtool autoconf bison
    wget -q http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz
    tar -xf afl-latest.tgz
    rm afl-latest.tgz
    (
        cd afl-*
        make -j$(nproc)
        (
            cd qemu_mode
            ./build_qemu_support.sh
        )
        sudo make install
    )
}

install_ropgadget() {
    git_clone https://github.com/JonathanSalwan/ROPgadget ROPgadget
    cd ROPgadget
    sudo python setup.py install
}

install_libheap() {
    git_clone https://github.com/cloudburst/libheap libheap
    sudo cp libheap/libheap.py /usr/lib/python3.4
    echo "# python from libheap import *" >> ~/.gdbinit
}

install_xrop() {
    git_clone https://github.com/acama/xrop.git xrop --depth 1
    cd xrop
    git submodule update --init --recursive

    # xrop does not support parallel build
    make
    sudo install -s xrop /usr/bin/xrop
}

install_qemu() {
    /vagrant/setup_qemu_arm.sh
}

init() {
    # Add 32-bit arch to dpkg
    sudo dpkg --add-architecture i386

    # Updates
    sudo apt-get -y update
    sudo apt-get -y upgrade

    # Install packages
    package \
        build-essential \
        emacs vim \
        git \
        python-pip python3-pip \
        python2.7 python2.7-dev libssl-dev libffi-dev \
        tmux \
        gdb gdb-multiarch \
        unzip \
        foremost \
        ipython ipython3

    # Install 32 bit libs
    package libc6:i386 libncurses5:i386 libstdc++6:i386 \
        libc6-dbg libc6-dbg:i386 \
        libc6-dev-i386

    # Fix urllib3 InsecurePlatformWarning
    sudo -H pip install --upgrade urllib3[secure]
}

# Only install if script is being executed, not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    set -e

    init

    cd $HOMEDIR
    mkdir -p tools

    install_ pwndbg true
    install_ peda false
    install_ pwntools
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
