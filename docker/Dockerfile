ARG BASE_IMAGE

# Start the builder stage running as native
FROM --platform=$BUILDPLATFORM "alpine:3.18" as builder

RUN apk add --no-cache squashfs-tools yq

# Install snap into /target
ARG TARGETARCH
COPY "files/radare2-${TARGETARCH}.sqsh" /tmp/radare2.sqsh
RUN mkdir -p /target/snap/radare2 /target/var/snap/radare2/current /target/var/snap/radare2/common && \
    unsquashfs -no-progress -dest "/target/snap/radare2/current" -excludes "/tmp/radare2.sqsh" snap

# Create base snap symlinks
RUN set -ex; BASE_SNAP=$(yq eval -o t .base /target/snap/radare2/current/meta/snap.yaml); \
    mkdir -p "/target/snap/${BASE_SNAP}"; ln -s "/" "/target/snap/${BASE_SNAP}/current"

# Create snap external command aliases
COPY "command.sh" /target/snap/bin/radare2
RUN set -ex; \
    for cmd in $(yq eval -o t '.apps | keys | .[] | select(. != "radare2")' \
        /target/snap/radare2/current/meta/snap.yaml); \
    do ln -s "radare2" "/target/snap/bin/radare2.$cmd"; done

# Start the final image stage
FROM "${BASE_IMAGE}" as radare2

# Create non-root user
RUN apt-get update && \
    apt-get install -y --no-install-recommends sudo python3-pip python3-setuptools && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -m r2 && \
    echo "r2 ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/r2 && \
    rm -vf /usr/lib/python*/EXTERNALLY-MANAGED && \
    pip3 install --no-cache-dir r2pipe

# Add image labels
ARG R2_VERSION
LABEL org.opencontainers.image.title="radare2" \
      org.opencontainers.image.description="UNIX-like reverse engineering framework and command-line toolset" \
      org.opencontainers.image.ref.name="radare/radare2" \
      org.opencontainers.image.version="${R2_VERSION}" \
      org.opencontainers.image.vendor="radareorg" \
      org.opencontainers.image.licenses="LGPL-3.0-only" \
      org.opencontainers.image.url="https://www.radare.org/" \
      org.opencontainers.image.source="https://github.com/radareorg/radare2-snap"

# Copy uncompressed snap files
ARG SNAP_ARCH
COPY --from=builder /target /

# Initialise base user
USER r2
WORKDIR /home/r2
ENV HOME="/home/r2" \
    PATH="/home/r2/.local/share/radare2/prefix/bin:/snap/radare2/current/usr/bin:/snap/radare2/current/bin:/snap/bin:${PATH}" \
    LD_LIBRARY_PATH="/home/r2/.local/share/radare2/prefix/lib:/snap/radare2/current/usr/lib:/snap/radare2/current/lib" \
    PKG_CONFIG_PATH="/home/r2/.local/share/radare2/prefix/lib/pkgconfig:/snap/radare2/current/usr/lib/pkgconfig:/snap/radare2/current/lib/pkgconfig" \
    R2_PREFIX="/snap/radare2/current/usr" \
    SLEIGHHOME="/snap/radare2/current/usr/lib/radare2/${R2_VERSION}" \
    SNAP="/snap/radare2/current" \
    SNAP_NAME="radare2" \
    SNAP_INSTANCE_NAME="radare2" \
    SNAP_VERSION="${R2_VERSION}" \
    SNAP_ARCH="${SNAP_ARCH}" \
    SNAP_REAL_HOME="/home/r2" \
    SNAP_USER_DATA="/home/r2/snap/radare2/current" \
    SNAP_USER_COMMON="/home/r2/snap/radare2/common" \
    SNAP_DATA="/var/snap/radare2/current" \
    SNAP_COMMON="/var/snap/radare2/common"
