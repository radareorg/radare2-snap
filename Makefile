# Makefile used only for local development tests

# This can be used to emulate the full build for a single arch (target: all)
# or to emulate only some part of the process (targets: snap snap-multiarch docker update map-docker-file)

# To use this makefile is required to have installed localy:
#  snap, snapcraft, squashfs-tools, docker, gh, yq (mikefarah)

DEB_HOST_ARCH?=$(shell type -p dpkg-architecture > /dev/null && dpkg-architecture -qDEB_HOST_ARCH || uname -m | sed -e 's,i[0-9]86,i386,g' -e 's,x86_64,amd64,g' -e 's,armv.*,armhf,g' -e 's,aarch64,arm64,g' -e 's,ppc.+64le,ppc64el,g')
TARGETARCH?=$(shell uname -m | sed -e 's,i[0-9]86,386,g' -e 's,x86_64,amd64,g' -e 's,armv.*,arm,g' -e 's,aarch64,arm64,g' -e 's,ppc.+64le,ppc64le,g')
DEB_BUILD_ARCH?=$(shell type -p dpkg-architecture > /dev/null && dpkg-architecture -qDEB_BUILD_ARCH || echo $(DEB_HOST_ARCH))
DOCKER_REPO?=radare2

.PHONY: all snap snap-multiarch docker update map-docker-files clean \
	build-snap build-snap-multiarch link-git-version-sqsh \
	download-snapcraft download-github download-github-artifacts

all: snap docker

snap: build-snap link-git-version-sqsh

snap-multiarch: build-snap-multiarch link-git-version-sqsh

docker: docker/Dockerfile docker/files/radare2-$(TARGETARCH).sqsh docker/files/radare2-$(TARGETARCH).snap.yaml
	$(eval R2_VERSION?=$(shell awk '/^version:/{gsub(/['\''"]/,"",$$2);print $$2;exit}' docker/files/radare2-$(TARGETARCH).snap.yaml))
	$(eval BASE_SNAP?=$(shell awk '/^base:/{print $$2;exit}' docker/files/radare2-$(TARGETARCH).snap.yaml))
	$(eval BASE_IMAGE?=ubuntu:$(BASE_SNAP:core%=%).04)
	docker build \
		--build-arg TARGETARCH=$(TARGETARCH) \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--build-arg BASE_SNAP=$(BASE_SNAP) \
		--build-arg R2_VERSION=$(R2_VERSION) \
		--tag "$(DOCKER_REPO):latest" \
		docker

# GitHub Actions scripts
update:
	.github/scripts/update-versions.sh
	-git status

map-docker-files:
	.github/scripts/map-docker-files.sh

# Clean environment
clean:
	-rm -Rf *.snap *.assert docker/files
	-docker rmi $(DOCKER_REPO):latest

# Helpers to build snap
build-snap: snap/snapcraft.yaml
	snapcraft --build-for=$(DEB_BUILD_ARCH)

build-snap-multiarch: snap/snapcraft.yaml
	snapcraft

link-git-version-sqsh:
	$(eval R2_VERSION?=$(shell awk '/^version:/{gsub(/['\''"]/,"",$$2);print $$2}' "snap/snapcraft.yaml"))
	mkdir -p docker/files
	ln -f "radare2_$(R2_VERSION)_$(DEB_BUILD_ARCH).snap" "docker/files/radare2-$(TARGETARCH).sqsh"

# Helpers to speedup docker tests that downloads the snap if possible
docker/files/radare2-$(TARGETARCH).sqsh:
	make $(shell type -p snap > /dev/null && echo download-snapcraft || type -p gh > /dev/null && echo download-github || echo snap) \
		DEB_BUILD_ARCH=$(DEB_BUILD_ARCH) \
		TARGETARCH=$(TARGETARCH)

download-snapcraft:
	UBUNTU_STORE_ARCH=$(DEB_BUILD_ARCH) snap download --basename="radare2__$(DEB_BUILD_ARCH)" radare2
	$(eval R2_VERSION?=$(shell sqfscat "radare2__$(DEB_BUILD_ARCH).snap" meta/snap.yaml | awk '/^version:/{gsub(/['\''"]/,"",$$2);print $$2;exit}'))
	mv "radare2__$(DEB_BUILD_ARCH).snap" "radare2_$(R2_VERSION)_$(DEB_BUILD_ARCH).snap"
	mkdir -p docker/files
	ln -f "radare2_$(R2_VERSION)_$(DEB_BUILD_ARCH).snap" "docker/files/radare2-$(TARGETARCH).sqsh"

download-github-artifacts:
	$(eval GH_RUN_DB_ID?=$(shell gh run list --workflow "Build images" --status completed --limit 1 --json "databaseId" --jq '.[].databaseId'))
	gh run download $(GH_RUN_DB_ID) -n snaps

download-github: download-github-artifacts
	$(eval SNAP_FILE?=$(shell ls -t radare2_*_$(DEB_BUILD_ARCH).snap | head -1))
	mkdir -p docker/files
	ln -f "$(SNAP_FILE)" "docker/files/radare2-$(TARGETARCH).sqsh"

# Extract snap metadata for docker generation
%.snap.yaml: %.sqsh
	sqfscat "$<" meta/snap.yaml > "$@"
