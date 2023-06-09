#!/bin/sh

set -e

cd "$(dirname "$0")/../.."

SNAP_CORE_YEAR=$(awk '/^base:/{sub(/core/,"",$2); print $2}' "snap/snapcraft.yaml")

echo "Clean old docker temporal files..."
rm -fR "docker/files"
mkdir -p "docker/files"

for SNAP_FILE in *.snap; do
  echo "Evaluating: ${SNAP_FILE}"
  SNAP_BASE=${SNAP_FILE%.snap}
  TARGETARCH=${SNAP_BASE##*_}
  RT=${SNAP_BASE%_*}
  R2_VERSION=${RT#*_}

  if [ "$TARGETARCH" = "armhf" ]; then
    TARGETARCH="arm"
  elif [ "$TARGETARCH" = "ppc64el" ]; then
    TARGETARCH="ppc64le"
  fi

  echo "Uncompressing ${TARGETARCH} files for radare2 version ${R2_VERSION}..."
  unsquashfs -no-progress -dest "docker/files/${TARGETARCH}" -excludes "${SNAP_FILE}" meta snap
  echo
done

echo "To build use SNAP_CORE_YEAR=${SNAP_CORE_YEAR} and R2_VERSION=${R2_VERSION}."

if [ -n "$GITHUB_OUTPUT" ]; then
  echo "snap_core_year=${SNAP_CORE_YEAR}" >> "$GITHUB_OUTPUT"
  echo "r2_version=${R2_VERSION}" >> "$GITHUB_OUTPUT"
fi
