#!/bin/sh

set -ae

cd "$(dirname "$0")/../.."

getLatestReleaseTag() {
  echo "Checking latest release version for $1..." > /dev/stderr
  gh release view --repo "$1" --json tagName --template '{{.tagName}}'
}

cat << EOF > versions.mk
R2_VERSION=$(getLatestReleaseTag radareorg/radare2)
R2GHIDRA_VERSION=$(getLatestReleaseTag radareorg/r2ghidra)
R2FRIDA_VERSION=$(getLatestReleaseTag nowsecure/r2frida)
R2DEC_VERSION=$(getLatestReleaseTag wargio/r2dec-js)
EOF
