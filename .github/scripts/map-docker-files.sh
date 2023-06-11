#!/bin/sh

set -e

cd "$(dirname "$0")/../.."

# create the docker file structure
mkdir -p "docker/files"
for SNAP_FILE in radare2_*.snap; do
  echo "Evaluating: ${SNAP_FILE}"
  SFBN=${SNAP_FILE%.snap}
  SNAP_ARCH=${SFBN##*_}

  case "$SNAP_ARCH" in
    armhf)    TARGETARCH="arm";;
    ppc64el)  TARGETARCH="ppc64le";;
    i386)     TARGETARCH="386";;
    *)        TARGETARCH=${SNAP_ARCH};;
  esac

  echo "Hard link radare2 snap ${SNAP_ARCH} to docker squashfs image for ${TARGETARCH}..."
  ln -fv "${SNAP_FILE}" "docker/files/radare2-${TARGETARCH}.sqsh"
  echo
done

# get metadata from any random snap file available
#  (the following lookup is not requiered while beeing after the for loop)
#  SNAP_FILE=$(ls -t radare2_*.snap | head -1)
SNAP_METADATA_FILE=$(mktemp)
echo "Extracting metadata from ${SNAP_FILE} to ${SNAP_METADATA_FILE}..."
sqfscat "${SNAP_FILE}" meta/snap.yaml > "${SNAP_METADATA_FILE}"
BASE_SNAP=$(awk '/^base:/{print $2;exit}' "${SNAP_METADATA_FILE}")
R2_VERSION=$(awk '/^version:/{gsub(/['\''"]/,"",$2);print $2;exit}' "${SNAP_METADATA_FILE}")
rm -f "${SNAP_METADATA_FILE}"

BASE_IMAGE="ubuntu:${BASE_SNAP#core}.04"
echo "To build use the following docker build args: BASE_IMAGE=${BASE_IMAGE} BASE_SNAP=${BASE_SNAP} R2_VERSION=${R2_VERSION}"

if [ -n "$GITHUB_OUTPUT" ]; then
  echo "base_image=${BASE_IMAGE}" >> "$GITHUB_OUTPUT"
  echo "base_snap=${BASE_SNAP}" >> "$GITHUB_OUTPUT"
  echo "r2_version=${R2_VERSION}" >> "$GITHUB_OUTPUT"
fi
