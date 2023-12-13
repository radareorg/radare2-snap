#!/bin/sh

COMMAND="$(basename "$0")"
exec /snap/radare2/current/bin/"${COMMAND#radare2.}" "$@"
