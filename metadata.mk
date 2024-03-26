DOCKER_TITLE=radare2
DOCKER_DESCRIPTION=UNIX-like reverse engineering framework and command-line toolset
DOCKER_VENDOR=radareorg
DOCKER_LICENSES=LGPL-3.0-only
DOCKER_HOMEPAGE_URL=https://www.radare.org/
DOCKER_DOCUMENTATION_URL=https://github.com/radareorg/radare2-snap/blob/main/README-containers.md
DOCKER_SOURCE_URL=https://github.com/radareorg/radare2-snap

# Docker labels included inside docker image config
DOCKER_LABELS= \
		--label org.opencontainers.image.title="$(DOCKER_TITLE)" \
		--label org.opencontainers.image.description="$(DOCKER_DESCRIPTION)" \
		--label org.opencontainers.image.ref.name="$(REGISTRY_IMAGE)" \
		--label org.opencontainers.image.version="$(R2_VERSION)" \
		--label org.opencontainers.image.vendor="$(DOCKER_VENDOR)" \
		--label org.opencontainers.image.licenses="$(DOCKER_LICENSES)" \
		--label org.opencontainers.image.url="$(DOCKER_HOMEPAGE_URL)" \
		--label org.opencontainers.image.documentation="$(DOCKER_DOCUMENTATION_URL)" \
		--label org.opencontainers.image.source="$(DOCKER_SOURCE_URL)" \
		--label org.opencontainers.image.revision="$(R2_SNAP_COMMIT)" \
		--label org.opencontainers.image.base.name="$(BASE_IMAGE)"

# Docker annotations for the repository manifest for the platform image
DOCKER_ANNOTATIONS_MANIFEST= \
		--annotation manifest:org.opencontainers.image.title="$(DOCKER_TITLE)" \
		--annotation manifest:org.opencontainers.image.description="$(DOCKER_DESCRIPTION)" \
		--annotation manifest:org.opencontainers.image.ref.name="$(REGISTRY_IMAGE)" \
		--annotation manifest:org.opencontainers.image.version="$(R2_VERSION)" \
		--annotation manifest:org.opencontainers.image.vendor="$(DOCKER_VENDOR)" \
		--annotation manifest:org.opencontainers.image.licenses="$(DOCKER_LICENSES)" \
		--annotation manifest:org.opencontainers.image.url="$(DOCKER_HOMEPAGE_URL)" \
		--annotation manifest:org.opencontainers.image.documentation="$(DOCKER_DOCUMENTATION_URL)" \
		--annotation manifest:org.opencontainers.image.source="$(DOCKER_SOURCE_URL)" \
		--annotation manifest:org.opencontainers.image.revision="$(R2_SNAP_COMMIT)" \
		--annotation manifest:org.opencontainers.image.base.name="$(BASE_IMAGE)"

# Docker annotations for the repository index referencing all platforms for a specific tag
# Note: Do not include ".image.base.*" since it is different for each platform
DOCKER_ANNOTATIONS_INDEX= \
		--annotation index:org.opencontainers.image.title="$(DOCKER_TITLE)" \
		--annotation index:org.opencontainers.image.description="$(DOCKER_DESCRIPTION)" \
		--annotation index:org.opencontainers.image.ref.name="$(REGISTRY_IMAGE)" \
		--annotation index:org.opencontainers.image.version="$(R2_VERSION)" \
		--annotation index:org.opencontainers.image.vendor="$(DOCKER_VENDOR)" \
		--annotation index:org.opencontainers.image.licenses="$(DOCKER_LICENSES)" \
		--annotation index:org.opencontainers.image.url="$(DOCKER_HOMEPAGE_URL)" \
		--annotation index:org.opencontainers.image.documentation="$(DOCKER_DOCUMENTATION_URL)" \
		--annotation index:org.opencontainers.image.source="$(DOCKER_SOURCE_URL)" \
		--annotation index:org.opencontainers.image.revision="$(R2_SNAP_COMMIT)"
