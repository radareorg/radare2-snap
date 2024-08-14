# Radare2 snap and docker repository

[![snap: radare2](https://snapcraft.io/radare2/badge.svg "snap latest stable version")](https://snapcraft.io/radare2)
[![docker: radare/radare2](https://img.shields.io/docker/pulls/radare/radare2?logo=docker&logoColor=white&label=radare%2Fradare2 "docker pulls")](https://hub.docker.com/r/radare/radare2)

This repository contains the recipie to build the snap version of radare2 using docker as well to build a standalone docker image with the same build.

The resulting build includes the following projects:

* [radare2](https://github.com/radareorg/radare2)
* [r2ghidra](https://github.com/radareorg/r2ghidra)
* [r2frida](https://github.com/nowsecure/r2frida) (only in supported platforms)
* [r2dec](https://github.com/wargio/r2dec-js)
* [r2yara](https://github.com/radareorg/r2yara)
* [r2book](https://github.com/radareorg/radare2-book) (as `info` file)

## Install the snap

[![Get it from the Snap Store](https://snapcraft.io/static/images/badges/en/snap-store-black.svg)](https://snapcraft.io/radare2)

Radare requires snap classic confinement, to install run:

```sh
sudo snap install radare2 --classic
```

Once installed all radare commands are available as:
`radare2.<command>` (ex: `radare2.rasm2`).

To allow using radare commands without this prefix, it can be solved either by using shell alias or by adding `/snap/radare2/current/bin` to your `PATH` environment.
Also if `r2pm` gets used it can also be useful to add the user local prefix `~/.local/share/radare2/prefix/bin`.

So as an example could be somthing like this:

```sh
PATH="$HOME/.local/share/radare2/prefix/bin:/snap/radare2/current/bin:$PATH"
```

## The docker image

As explained, with the same snap build a [docker image](https://hub.docker.com/r/radare/radare2) is generated.

For documentation on how to use this docker image you can refer to [containers section](README-containers.md) in this respository.
