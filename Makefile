# Makefile used only for local development tests

# This can be used to emulate the full build for a single arch (target: all)
# to perform a full build locally (target: all-multiarch)
# or to emulate only some parts of the process (targets: snap docker snap-multiarch docker-multiarch)

# To use this makefile is required to have installed localy:
#  snap, snapcraft, squashfs-tools, docker, docker-buildx

SNAP_CORE_YEAR?=$(shell awk '/^base:/{sub(/core/,"",$$2); print $$2}' "snap/snapcraft.yaml")
R2_VERSION?=$(shell awk '/^version:/{gsub(/['\''"]/,"",$$2); print $$2}' "snap/snapcraft.yaml")
DOCKER_REPO?=radare2

.PHONY: all snap docker all-multiarch snap-multiarch docker-multiarch clean

all: snap docker
all-multiarch: snap-multiarch docker-multiarch

snap:
	$(eval DEB_HOST_ARCH?=$(shell dpkg-architecture -qDEB_HOST_ARCH || dpkg --print-architecture || docker run --rm "ubuntu:$(SNAP_CORE_YEAR).04" dpkg --print-architecture))
	snapcraft --build-for=$(DEB_HOST_ARCH)
	mkdir -p docker/files
	-rm -f docker/files/radare2__host.snap
	ln -fs "../../radare2_$(R2_VERSION)_$(DEB_HOST_ARCH).snap" "docker/files/radare2__host.snap"

docker/files/radare2__host.snap:
	snap download --target-directory="docker/files/" --basename="radare2__host" radare2

docker/files/host: docker/files/radare2__host.snap
	unsquashfs -dest "docker/files/host" -excludes "docker/files/radare2__host.snap" meta snap

docker: docker/files/host
	$(eval R2_VERSION_HOST?=$(shell readlink docker/files/host/usr/share/radare2/last))
	docker build \
		--build-arg SNAP_CORE_YEAR=$(SNAP_CORE_YEAR) \
		--build-arg IMAGEREFNAME=$(DOCKER_REPO) \
		--build-arg R2_VERSION=$(R2_VERSION_HOST) \
		--build-arg TARGETARCH=host \
		--tag "$(DOCKER_REPO):latest" \
		--tag "$(DOCKER_REPO):$(R2_VERSION_HOST)" \
		docker

snap-multiarch:
	snapcraft
	-rm -f docker/files/.docker-multiarch

docker/files/.docker-multiarch:
	.github/scripts/extract-docker-files.sh
	touch docker/files/.docker-multiarch

docker-multiarch: docker/files/.docker-multiarch
	cd docker && \
		REPO=$(DOCKER_REPO) R2_VERSION=$(R2_VERSION) SNAP_CORE_YEAR=$(SNAP_CORE_YEAR) \
		docker buildx bake --pull --load

clean:
	-rm -Rf *.snap docker/files
	-docker rmi $(DOCKER_REPO):latest $(DOCKER_REPO):$(R2_VERSION)