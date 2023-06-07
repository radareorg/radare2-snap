# Makefile used only for local development tests

# This can be used to emulate the full build for a single arch (target: all)
# to perform a full build locally (target: all-multiarch)
# or to emulate only some parts of the process (targets: snap docker snap-multiarch docker-multiarch)

# To use this makefile is required to have installed localy:
#  snap, snapcraft, squashfs-tools, docker, docker-buildx

SNAP_CORE_YEAR?=$(shell awk '/^base:/{sub(/core/,"",$$2); print $$2}' "snap/snapcraft.yaml")
R2_VERSION?=$(shell awk '/^version:/{gsub(/['\''"]/,"",$$2); print $$2}' "snap/snapcraft.yaml")

.PHONY: all snap docker all-multiarch snap-multiarch docker-multiarch clean

all: snap docker
all-multiarch: snap-multiarch docker-multiarch

snap:
	$(eval DEB_HOST_ARCH?=$(shell dpkg-architecture -qDEB_HOST_ARCH || dpkg --print-architecture || docker run --rm "ubuntu:$(SNAP_CORE_YEAR).04" dpkg --print-architecture))
	snapcraft --build-for=$(DEB_HOST_ARCH)

docker/files/host:
	mkdir -p docker/files
	snap download --target-directory="docker/files/" --basename="radare2__host" radare2
	unsquashfs -dest "docker/files/host" -excludes "docker/files/radare2__host.snap" meta snap

docker: docker/files/host
	docker build \
		--build-arg SNAP_CORE_YEAR=$(SNAP_CORE_YEAR) \
		--build-arg R2_VERSION=$(shell readlink docker/files/host/usr/share/radare2/last) \
		--build-arg TARGETARCH=host \
		--build-arg IMAGEREFNAME=radare2 \
		--tag radare2:latest \
		docker

snap-multiarch:
	snapcraft
	-rm -f docker/files/.docker-multiarch

docker/files/.docker-multiarch:
	.github/scripts/extract-docker-files.sh
	touch docker/files/.docker-multiarch

docker-multiarch: docker/files/.docker-multiarch
	cd docker && \
		SNAP_CORE_YEAR=$(SNAP_CORE_YEAR) R2_VERSION=$(R2_VERSION) REPO="radare2" \
		docker buildx bake --pull --load

clean:
	-rm -Rf *.snap docker/files
	-docker rmi radare2:latest