# Radare2 snap repository

[![radare2](https://snapcraft.io/radare2/badge.svg)](https://snapcraft.io/radare2)

This repository contains the recipie to build the snap version of radare2.

The resulting build includes the following projects:

* [radare2](https://github.com/radareorg/radare2)
* [r2ghidra](https://github.com/radareorg/r2ghidra)
* [r2frida](https://github.com/nowsecure/r2frida)
* [r2dec](https://github.com/wargio/r2dec-js)

## Install snap

Radare requires snap classic confinement, to install run:
```
sudo snap install radare2 --classic
```
Once installed all radare commands are available as:
`radare2.<command>` (ex: `radare2.rasm2`).


[![Get it from the Snap Store](https://snapcraft.io/static/images/badges/en/snap-store-black.svg)](https://snapcraft.io/radare2)

## Docker

With the same snap build a docker image is also generated.

To use the docker image:
```
docker run --rm -ti radare/radare2
```

And to use debugging with docker:
```
docker run --rm --tty --interactive --privileged --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --security-opt apparmor=unconfined radare/radare2
```
