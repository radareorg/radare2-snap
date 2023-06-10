#!/bin/sh

set -e

cd "$(dirname "$0")/../.."

SNAP_CORE_YEAR=$(awk '/^base:/{sub(/core/,"",$2); print $2}' "snap/snapcraft.yaml")

echo "Clean old docker temporal files..."
rm -fR "docker/files"
mkdir -p "docker/files"

for SNAP_FILE in radare2_*.snap; do
  echo "Evaluating: ${SNAP_FILE}"
  SNAP_BASE=${SNAP_FILE%.snap}
  SNAP_ARCH=${SNAP_BASE##*_}
  RT=${SNAP_BASE%_*}
  SNAP_VERSION=${RT#*_}

  case "$SNAP_ARCH" in
    armhf)    TARGETARCH="arm";;
    ppc64el)  TARGETARCH="ppc64le";;
    i386)     TARGETARCH="386";;
    *)        TARGETARCH=${SNAP_ARCH};;
  esac

  if [ "${SNAP_VERSION}" != "latest" ]; then
    R2_VERSION=${SNAP_VERSION}
  fi

  echo "Uncompressing ${TARGETARCH} files for radare2 version ${SNAP_VERSION}..."
  unsquashfs -no-progress -dest "docker/files/${TARGETARCH}" -excludes "${SNAP_FILE}" meta snap
  echo
done

echo "To build use SNAP_CORE_YEAR=${SNAP_CORE_YEAR} and R2_VERSION=${R2_VERSION}."

if [ -n "$GITHUB_OUTPUT" ]; then
  echo "snap_core_year=${SNAP_CORE_YEAR}" >> "$GITHUB_OUTPUT"
  echo "r2_version=${R2_VERSION}" >> "$GITHUB_OUTPUT"
fi
