# Makefile used only for local development tests

# This can be used to emulate the full build for a single arch (target: all)
# or to emulate only some part of the process (targets: snap snap-multiarch docker)

# To use this makefile is required to have installed localy:
#  snap, snapcraft, squashfs-tools, docker, gh, yq (mikefarah)

SNAP_CORE_YEAR?=$(shell awk '/^base:/{sub(/core/,"",$$2); print $$2}' "snap/snapcraft.yaml")
R2_VERSION?=$(shell awk '/^version:/{gsub(/['\''"]/,"",$$2); print $$2}' "snap/snapcraft.yaml")
DEB_HOST_ARCH?=$(shell dpkg-architecture -qDEB_HOST_ARCH || dpkg --print-architecture || docker run --rm "ubuntu:$(SNAP_CORE_YEAR).04" dpkg --print-architecture)
DOCKER_REPO?=radare2

.PHONY: all snap docker snap-multiarch download-snapcraft download-github update clean

all: snap docker

snap:
	snapcraft --build-for=$(DEB_HOST_ARCH)
	ln -fs "radare2_$(R2_VERSION)_$(DEB_HOST_ARCH).snap" "radare2_latest_host.snap"

radare2_latest_host.snap:
	make download-snapcraft || make download-github || make snap

docker/files/host: | radare2_latest_host.snap
	mkdir -p docker/files
	unsquashfs -dest "$@" -excludes "radare2_latest_host.snap" meta snap

docker: docker/files/host
	$(eval R2_VERSION_HOST?=$(shell readlink docker/files/host/usr/share/radare2/last))
	docker build \
		--build-arg SNAP_CORE_YEAR=$(SNAP_CORE_YEAR) \
		--build-arg IMAGEREFNAME=$(DOCKER_REPO) \
		--build-arg R2_VERSION=$(R2_VERSION_HOST) \
		--build-arg TARGETARCH=host \
		--tag "$(DOCKER_REPO):latest" \
		docker

snap-multiarch:
	snapcraft

download-snapcraft:
	snap download --basename="radare2-latest-host" radare2

download-github:
	$(eval GH_RUN_DB_ID?=$(shell gh run list --workflow "Build images" --limit 1 --json "databaseId" --jq '.[].databaseId'))	
	gh run download $(GH_RUN_DB_ID) -n snaps
	ln -fs "radare2_$(R2_VERSION)_$(DEB_HOST_ARCH).snap" "radare2_latest_host.snap"

update:
	.github/scripts/update-versions.sh
	-git status

clean:
	-rm -Rf *.snap docker/files
	-docker rmi $(DOCKER_REPO):latest
