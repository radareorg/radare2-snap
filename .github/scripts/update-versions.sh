#!/bin/sh

set -ae

cd "$(dirname "$0")/../.."

getLatestReleaseTag() {
  echo "Checking latest release version for $1..." > /dev/stderr
  gh release view --repo "$1" --json tagName --template '{{.tagName}}'
}

R2_VERSION=$(getLatestReleaseTag radareorg/radare2)
R2GHIDRA_VERSION=$(getLatestReleaseTag radareorg/r2ghidra)
R2FRIDA_VERSION=$(getLatestReleaseTag nowsecure/r2frida)
R2DEC_VERSION=$(getLatestReleaseTag wargio/r2dec-js)

echo "Updating versions in snapcraft.yaml..." > /dev/stderr
yq eval -i '.version=strenv(R2_VERSION) | 
  .parts.r2ghidra.source-tag=strenv(R2GHIDRA_VERSION) |
  .parts.r2frida.source-tag=strenv(R2FRIDA_VERSION) |
  .parts.r2dec.source-tag=strenv(R2DEC_VERSION)
  ' snap/snapcraft.yaml

