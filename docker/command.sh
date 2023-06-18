#!/bin/sh

COMMAND="$(basename "$0")"
exec /snap/radare2/current/usr/bin/"${COMMAND#radare2.}" "$@"
