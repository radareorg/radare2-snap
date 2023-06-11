FROM --platform=$BUILDPLATFORM alpine:3.18 AS builder

RUN apk add --no-cache squashfs-tools yq

COPY "command.sh" /target/snap/bin/radare2

ARG TARGETARCH
COPY "files/radare2-${TARGETARCH}.sqsh" /tmp/radare2.sqsh

RUN unsquashfs -no-progress -dest "/target/app" -excludes "/tmp/radare2.sqsh" meta snap

RUN set -ex; \
    for cmd in $(sqfscat "/tmp/radare2.sqsh" meta/snap.yaml | \
            yq eval -o t '.apps | keys | .[] | select(. != "radare2")'); do \
        ln -s "radare2" "/target/snap/bin/radare2.$cmd"; \
    done;

ARG BASE_IMAGE
FROM ${BASE_IMAGE}

# Replicate snap structure and create non-root user
ARG BASE_SNAP
RUN mkdir -p "/snap/${BASE_SNAP}" "/snap/radare2" "/var/snap/radare2" "/var/app" && \
    ln -s "/" "/snap/${BASE_SNAP}/current" && \
    ln -s "/app" "/snap/radare2/current" && \
    ln -s "/var/app" "/var/snap/radare2/current" && \
    ln -s "/var/app" "/var/snap/radare2/common" && \
    apt-get update && \
    apt-get install -y sudo && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -m r2 && \
    echo "r2 ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/r2

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
    SNAP_REAL_HOME="/home/r2" \
    SNAP_USER_DATA="/home/r2" \
    SNAP_USER_COMMON="/home/r2" \
    SNAP_DATA="/var/app" \
    SNAP_COMMON="/var/app"
