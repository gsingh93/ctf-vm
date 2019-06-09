# CTF VM

An Ubuntu 18.04 x64 VM for binary exploitation and reversing CTF problems. For a 16.04/14.04 VM, checkout the `ubuntu16.04` and `ubuntu14.04` branches. For a Windows 7 CTF VM, see https://github.com/gsingh93/ctf-vm-windows7.

## Installation

```
git clone git@github.com:gsingh93/ctf-vm.git
cd ctf-vm
vagrant up
```

## Packages

Included packages

- pwndbg
- peda
- pwntools
- Pin
- AFL (currently disabled on 18.04)
- ROPgadget
- rp++
- xrop
- one_gadget
- QEMU with ARM support
- angr
- frida
