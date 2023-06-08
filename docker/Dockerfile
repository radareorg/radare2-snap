ARG SNAP_CORE_YEAR
FROM ubuntu:"${SNAP_CORE_YEAR}.04"

# Replicate snap structure and create non-root user
ARG SNAP_CORE_YEAR
RUN mkdir -p "/snap/core${SNAP_CORE_YEAR}" "/snap/radare2" "/var/snap/radare2" "/var/app" && \
    ln -s "/" "/snap/core${SNAP_CORE_YEAR}/current" && \
    ln -s "/app" "/snap/radare2/current" && \
    ln -s "/var/app" "/var/snap/radare2/current" && \
    ln -s "/var/app" "/var/snap/radare2/common" && \
    useradd -m r2 && \
    adduser r2 sudo && \
    echo "r2:r2" | chpasswd

# Copy uncompressed snap files into /app
ARG TARGETARCH
COPY "files/${TARGETARCH}" /app

# Initialise base user
USER r2
WORKDIR /home/r2

ARG R2_VERSION
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
