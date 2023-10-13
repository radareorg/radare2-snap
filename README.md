# Radare2 snap and docker repository

[![snap: radare2](https://snapcraft.io/radare2/badge.svg "snap latest stable version")](https://snapcraft.io/radare2)
[![docker: radare/radare2](https://img.shields.io/docker/pulls/radare/radare2?logo=docker&logoColor=white&label=radare%2Fradare2 "docker pulls")](https://hub.docker.com/r/radare/radare2)

This repository contains the recipie to build the snap version of radare2 using docker as well to build a standalone docker image with the same build.

The resulting build includes the following projects:

* [radare2](https://github.com/radareorg/radare2)
* [r2ghidra](https://github.com/radareorg/r2ghidra)
* [r2frida](https://github.com/nowsecure/r2frida) (only in supported platforms)
* [r2dec](https://github.com/wargio/r2dec-js)

## Install the snap

Radare requires snap classic confinement, to install run:
```
sudo snap install radare2 --classic
```
Once installed all radare commands are available as:
`radare2.<command>` (ex: `radare2.rasm2`).


[![Get it from the Snap Store](https://snapcraft.io/static/images/badges/en/snap-store-black.svg)](https://snapcraft.io/radare2)

## Use the docker image

As explained, with the same snap build a [docker image](https://hub.docker.com/r/radare/radare2) is generated.

To use the docker image you can use either:
```
docker run -ti radare/radare2
podman run -ti docker.io/radare/radare2
nerdctl run -ti radare/radare2
```

To use the docker image as one shot so it removes everything inside the container on exit just add `--rm` as follows:
```
docker run --rm -ti radare/radare2
```

Another example to use for debugging inside the docker:
```
docker run --tty --interactive --privileged --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --security-opt apparmor=unconfined radare/radare2
```
