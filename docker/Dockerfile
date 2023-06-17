ARG BASE_IMAGE

# Start the builder stage running as native
FROM --platform=$BUILDPLATFORM "alpine:3.18" as builder

RUN apk add --no-cache squashfs-tools yq

# Uncompress snap to /target/app
ARG TARGETARCH
COPY "files/radare2-${TARGETARCH}.sqsh" /tmp/radare2.sqsh
RUN mkdir /target && \
    unsquashfs -no-progress -dest "/target/app" -excludes "/tmp/radare2.sqsh" snap && \
    mv /target/app/meta /tmp/

# Replicate snap structure
RUN set -ex; BASE_SNAP=$(yq eval -o t .base /tmp/meta/snap.yaml); \
    mkdir -p "/target/snap/${BASE_SNAP}" "/target/snap/radare2" "/target/var/snap/radare2" "/target/var/app"; \
    ln -s "/" "/target/snap/${BASE_SNAP}/current"; \
    ln -s "/app" "/target/snap/radare2/current"; \
    ln -s "/var/app" "/target/var/snap/radare2/current"; \
    ln -s "/var/app" "/target/var/snap/radare2/common"

# Create snap external command aliases
COPY "command.sh" /target/snap/bin/radare2
RUN set -ex; \
    for cmd in $(yq eval -o t '.apps | keys | .[] | select(. != "radare2")' /tmp/meta/snap.yaml); \
    do ln -s "radare2" "/target/snap/bin/radare2.$cmd"; done

# Start the final image stage
FROM "${BASE_IMAGE}" as radare2

# Create non-root user
RUN apt-get update && \
    apt-get install -y --no-install-recommends sudo python3-pip python3-setuptools && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -m r2 && \
    echo "r2 ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/r2 && \
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
    PATH="/app/usr/bin:/app/bin:/snap/bin:${PATH}" \
    R2_PREFIX="/app/usr" \
    SLEIGHHOME="/app/usr/lib/radare2/last" \
    SNAP="/app" \
    SNAP_NAME="radare2" \
    SNAP_VERSION="${R2_VERSION}" \
    SNAP_ARCH="${SNAP_ARCH}" \
    SNAP_REAL_HOME="/home/r2" \
    SNAP_USER_DATA="/home/r2" \
    SNAP_USER_COMMON="/home/r2" \
    SNAP_DATA="/var/app" \
    SNAP_COMMON="/var/app"
