BASE_IMAGE=docker.io/library/ubuntu:22.04
BASE_SNAP=core22

TARGETPLATFORM=linux/arm/v7
MULTIARCH=arm-linux-gnueabihf
# Issue building frida (temporally disabled)
# FRIDA_ARCH=armhf
FRIDA_ARCH=
