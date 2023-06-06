ARG SNAP_CORE_YEAR
FROM ubuntu:"${SNAP_CORE_YEAR}.04"
ARG SNAP_CORE_YEAR
ARG TARGETARCH
ARG IMAGEREFNAME
ARG R2_VERSION

LABEL org.opencontainers.image.title="radare2" \
      org.opencontainers.image.description="UNIX-like reverse engineering framework and command-line toolset" \
      org.opencontainers.image.ref.name="${IMAGEREFNAME}" \
      org.opencontainers.image.version="${R2_VERSION}" \
      org.opencontainers.image.vendor="radareorg" \
      org.opencontainers.image.licenses="LGPL-3.0-only" \
      org.opencontainers.image.url="https://www.radare.org/" \
      org.opencontainers.image.source="https://github.com/radareorg/radare2-snap"

# Copy uncompressed .snap into /app
COPY "files/${TARGETARCH}" /app

# Replicate snap structure and create non-root user
RUN mkdir -p "/snap/core${SNAP_CORE_YEAR}" "/snap/radare2" "/var/app" "/var/snap/radare2" && \
    ln -s "/" "/snap/core${SNAP_CORE_YEAR}/current" && \
    ln -s "/app" "/snap/radare2/current" && \
    ln -s "/var/app" "/var/snap/radare2/current" && \
    ln -s "/var/app" "/var/snap/radare2/common" && \
    useradd -m r2 && \
    adduser r2 sudo && \
    echo "r2:r2" | chpasswd

# Initialise base user
USER r2
WORKDIR /home/r2

ENV HOME="/home/r2" \
    PATH="/app/usr/bin:/app/bin:${PATH}" \
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
