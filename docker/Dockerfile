ARG BASE_IMAGE
ARG ALPINE_VERSION=3.20

## Native build cross platform
FROM "$BASE_IMAGE" as native-builder

ARG BASE_SNAP
ARG MESON_VERSION
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        g++ \
        gcc \
        git \
        libc-dev \
        make \
        patch \
        pkg-config \
        xz-utils \
        python3-pip \
        python3-venv \
        ninja-build \
        autoconf \
        automake \
        bison \
        flex \
        libtool \
        libssl-dev \
        && \
    rm -rf /var/lib/apt/lists/* && \
    python3 -m venv /opt/meson && /opt/meson/bin/pip3 install "meson~=${MESON_VERSION}" && \
    mkdir -p "/snap/${BASE_SNAP}" && \
    ln -s "/" "/snap/${BASE_SNAP}/current"

WORKDIR /usr/src
ENV PREFIX="/snap/radare2/current" \
    PATH="/snap/radare2/current/bin:$PATH:/opt/meson/bin" \
    LD_LIBRARY_PATH="/snap/radare2/current/lib" \
    PKG_CONFIG_PATH="/snap/radare2/current/lib/pkgconfig" \
    CFLAGS="-O3"

# Build radare2
ARG R2_VERSION
RUN curl -L "https://github.com/radareorg/radare2/releases/download/${R2_VERSION}/radare2-${R2_VERSION}.tar.xz" | tar -xJ && \
    cd "radare2-${R2_VERSION}" && \
    ./configure --prefix="$PREFIX" --with-checks-level=0 && \
    make && make install

# Build r2ghidra
ARG R2GHIDRA_VERSION
RUN git clone --branch "$R2GHIDRA_VERSION" --recurse-submodules --depth 1 https://github.com/radareorg/r2ghidra.git && \
    cd r2ghidra && \
    ./preconfigure && \
    ./configure --prefix="$PREFIX" --with-checks-level=0 && \
    make && make install

# Build r2frida (optional)
ARG R2FRIDA_VERSION
ARG FRIDA_ARCH
RUN if [ -n "$FRIDA_ARCH" ]; then \
        git clone --branch "$R2FRIDA_VERSION" --recurse-submodules --depth 1 https://github.com/nowsecure/r2frida.git && \
        cd r2frida && \
        ./configure --prefix="$PREFIX" --with-checks-level=0 && \
        R2PM_OFFLINE="yes" make frida_arch="$FRIDA_ARCH" && make install frida_arch="$FRIDA_ARCH"; \
    fi

# Build r2dec
ARG R2DEC_VERSION
RUN git clone --branch "$R2DEC_VERSION" --recurse-submodules --depth 1 https://github.com/wargio/r2dec-js.git && \
    cd r2dec-js && \
    meson setup --prefix "$PREFIX" build && \
    ninja -C build install

# Build r2yara
## Compile yara dependency
ARG YARA_VERSION
RUN git clone --branch "v$YARA_VERSION" --recurse-submodules --depth 1 https://github.com/VirusTotal/yara.git && \
    cd yara && \
    ./bootstrap.sh && \
    ./configure --prefix="$PREFIX" && \
    make && make install
## Compile r2yara plugin
ARG R2YARA_VERSION
RUN git clone --branch "$R2YARA_VERSION" --recurse-submodules --depth 1 https://github.com/radareorg/r2yara.git && \
    cd r2yara && \
    ./configure --prefix="$PREFIX" --with-checks-level=0 && \
    make && make install

## Final build: patch elfs and generate metadata
FROM --platform=$BUILDPLATFORM "alpine:${ALPINE_VERSION}" as builder

RUN apk add --no-cache yq-go gettext-envsubst patchelf

ENV PREFIX="/snap/radare2/current"
COPY --from=native-builder /snap /snap

# patchelf
# An alternative to use patchelf is to build with
# LDFLAGS="-Wl,-rpath='\$\$ORIGIN/../lib' -Wl,-dynamic-linker=${DYNAMIC_LINKER}"
ARG R2_VERSION
ARG BASE_SNAP
ARG MULTIARCH
RUN BASE_PATH="/snap/$BASE_SNAP/current" LIBRARY_PATH="$BASE_PATH/lib/$MULTIARCH" DYNAMIC_LINKER=$(patchelf --print-interpreter "$PREFIX/bin/radare2") && \
    find "$PREFIX/bin" -maxdepth 1 -type f -exec patchelf --set-interpreter "${BASE_PATH}${DYNAMIC_LINKER}" --force-rpath --set-rpath "\$ORIGIN/../lib:$LIBRARY_PATH" \{\} \+ && \
    find "$PREFIX/lib" -maxdepth 1 -name \*.so\* -type f -exec patchelf --force-rpath --set-rpath "\$ORIGIN:$LIBRARY_PATH" \{\} \+ && \
    find "$PREFIX/lib/radare2/$R2_VERSION" -maxdepth 1 -name \*.so\* -type f -exec patchelf --force-rpath --set-rpath "\$ORIGIN/../..:$LIBRARY_PATH" \{\} \+

# Generate SBOM files
ARG FRIDA_ARCH
ARG R2_SNAP_COMMIT
ARG R2DEC_VERSION
ARG R2FRIDA_VERSION
ARG R2GHIDRA_VERSION
ARG R2YARA_VERSION
ARG YARA_VERSION
COPY sbom /usr/src/sbom
RUN set -e; \
    OUT_DIR="$PREFIX/share/sbom"; mkdir -p "$OUT_DIR"; cd "/usr/src/sbom"; \
    for IN_SPDX in *.spdx.*.in; do PKG_SPDX="${IN_SPDX%.spdx.*}"; \
        [ "$PKG_SPDX" = "r2frida" -a -z "$FRIDA_ARCH" ] && continue; \
        OUT_SPDX="${OUT_DIR}/${IN_SPDX%.in}"; \
        echo "Generate SBOM from ${IN_SPDX} to ${OUT_SPDX}..."; \
        envsubst < "$IN_SPDX" > "$OUT_SPDX"; \
    done

# Create snap metadata and docker alias
COPY meta "$PREFIX/meta"
COPY "command.sh" /snap/bin/radare2
ARG SNAP_ARCH
RUN set -ex; \
    yq eval -i ".version=\"$R2_VERSION\" | .base=\"$BASE_SNAP\" | .architectures=[\"$SNAP_ARCH\"]" "$PREFIX/meta/snap.yaml"; \
    for f in "$PREFIX/bin/"* ; do c=$(basename "$f"); \
    yq eval -i ".apps[\"$c\"].command=\"bin/$c\"" "$PREFIX/meta/snap.yaml"; \
    [ "$c" != "radare2" ] && ln -s "radare2" "/snap/bin/radare2.$c"; \
    done

## Build snap file
FROM --platform=$BUILDPLATFORM "alpine:${ALPINE_VERSION}" as snapbuilder

RUN apk add --no-cache squashfs-tools
COPY --from=builder /snap/radare2/current /snap/radare2/current

ARG R2_VERSION
ARG SNAP_ARCH
RUN mksquashfs /snap/radare2/current "/root/radare2_${R2_VERSION}_${SNAP_ARCH}.snap" -comp lzo -all-root -no-xattrs -no-fragments

## Export snap file
FROM --platform=$BUILDPLATFORM scratch as snap

COPY --from=snapbuilder /root/*.snap /

## Docker final image
FROM "${BASE_IMAGE}" as docker

# Create non-root user
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        sudo \
        openssl \
        python3-pip \
        python3-setuptools \
        && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/snap/radare2/current /var/snap/radare2/common && \
    useradd -m r2 && \
    echo "r2 ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/r2 && \
    rm -vf /usr/lib/python*/EXTERNALLY-MANAGED && \
    pip3 install --no-cache-dir r2pipe

# Copy uncompressed snap files
ARG SNAP_ARCH
COPY --from=builder /snap /snap

# Initialise base user
ARG R2_VERSION
USER r2
WORKDIR /home/r2
ENV HOME="/home/r2" \
    PATH="/home/r2/.local/share/radare2/prefix/bin:/snap/radare2/current/bin:/snap/bin:${PATH}" \
    LD_LIBRARY_PATH="/home/r2/.local/share/radare2/prefix/lib:/snap/radare2/current/lib" \
    PKG_CONFIG_PATH="/home/r2/.local/share/radare2/prefix/lib/pkgconfig:/snap/radare2/current/lib/pkgconfig" \
    R2_PREFIX="/snap/radare2/current" \
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
