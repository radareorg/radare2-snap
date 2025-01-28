#!/bin/sh

set -ae

cd "$(dirname "$0")/../.."

getLatestReleaseTag() {
  echo "Checking latest release version for $1..." > /dev/stderr
  V=$(gh release view --repo "$1" --json tagName --template '{{.tagName}}')
  if [ -n "$2" ]; then V="${V#$2}"; fi
  if [ -n "$3" ]; then V="${V%$3}"; fi
  echo "$V"
}

cat << EOF > versions.mk
R2_VERSION=$(getLatestReleaseTag radareorg/radare2)
R2GHIDRA_VERSION=$(getLatestReleaseTag radareorg/r2ghidra)
R2FRIDA_VERSION=$(getLatestReleaseTag nowsecure/r2frida)
YARA_VERSION=$(getLatestReleaseTag VirusTotal/yara v)
R2YARA_VERSION=$(getLatestReleaseTag radareorg/r2yara)
R2AI_VERSION=$(getLatestReleaseTag radareorg/r2ai)
R2BOOK_VERSION=$(getLatestReleaseTag radareorg/radare2-book)
EOF
