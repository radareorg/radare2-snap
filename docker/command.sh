#!/bin/sh

COMMAND="$(basename "$0")"
exec /app/usr/bin/"${COMMAND#radare2.}" "$@"
