#!/bin/sh

set -e

REGISTRY_IMAGE=${REGISTRY_IMAGE:-radare/radare2}

cd "$(dirname "$0")/.."

WORKDIR=$(mktemp -d)
DOCKER_SOURCES_FILE="${WORKDIR}/docker-sources"
rm -f "${DOCKER_SOURCES_FILE}"

for SNAP_FILE in $(find snapcraft -name radare2_\*.snap); do
  echo "Evaluating: ${SNAP_FILE}"
  SFBN=$(basename "$SNAP_FILE" .snap)
  SNAP_ARCH=${SFBN##*_}

  BASE_IMAGE="ubuntu"
  TARGETPLATFORM=""
  case "$SNAP_ARCH" in
    armhf)    TARGETARCH="arm"; TARGETPLATFORM="linux/arm/v7";;
    ppc64el)  TARGETARCH="ppc64le";;
    i386)     TARGETARCH="386";;
    riscv64)  TARGETARCH="riscv64"; BASE_IMAGE="riscv64/ubuntu";;
    *)        TARGETARCH="${SNAP_ARCH}";;
  esac
  TARGETPLATFORM=${TARGETPLATFORM:-"linux/${TARGETARCH}"}

  echo "Clean docker files..."
  rm -fR "docker/files"
  mkdir -p "docker/files"

  echo "Hard link radare2 snap ${SNAP_ARCH} to docker squashfs image for ${TARGETARCH}..."
  SQSH_FILE="docker/files/radare2-${TARGETARCH}.sqsh"
  ln -v "${SNAP_FILE}" "${SQSH_FILE}"

  SNAP_METADATA_FILE="${WORKDIR}/radare2-${TARGETARCH}.snap.yaml"
  echo "Extracting metadata from ${SNAP_FILE} to ${SNAP_METADATA_FILE}..."
  sqfscat "${SNAP_FILE}" meta/snap.yaml > "${SNAP_METADATA_FILE}"
  BASE_SNAP=$(awk '/^base:/{print $2;exit}' "${SNAP_METADATA_FILE}")
  R2_VERSION=$(awk '/^version:/{gsub(/['\''"]/,"",$2);print $2;exit}' "${SNAP_METADATA_FILE}")
  BASE_IMAGE="${BASE_IMAGE}:${BASE_SNAP#core}.04"
  IID_FILE="${WORKDIR}/iidfile-${TARGETARCH}"

  echo "Building docker image to ${TARGETPLATFORM} using ${BASE_IMAGE}..."
  docker buildx build \
    --build-arg "BASE_IMAGE=${BASE_IMAGE}" \
    --build-arg "R2_VERSION=${R2_VERSION}" \
    --build-arg "SNAP_ARCH=${SNAP_ARCH}" \
    --platform "${TARGETPLATFORM}" \
    --iidfile "${IID_FILE}" \
    --output "type=image,name=${REGISTRY_IMAGE},push-by-digest=true,name-canonical=true,push=true" \
    docker
  echo "${REGISTRY_IMAGE}@$(cat "${IID_FILE}")" >> "${DOCKER_SOURCES_FILE}"
done

# get metadata from any default snap file
R2_VERSION=$(awk '/^version:/{gsub(/['\''"]/,"",$2);print $2;exit}' "${WORKDIR}/radare2-amd64.snap.yaml")
echo "Pushing final docker image merged as ${REGISTRY_IMAGE}:${R2_VERSION}..."
docker buildx imagetools create \
  --tag "${REGISTRY_IMAGE}:latest" \
  --tag "${REGISTRY_IMAGE}:${R2_VERSION}" \
    $(cat "${DOCKER_SOURCES_FILE}")

echo "Clean workdir..."
rm -vfR "${WORKDIR}"
