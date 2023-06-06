# radare2-snap docker
Docker to run radare2 snap builds as a docker image.

To build this docker image you need to have the snap build extracted in the folder `files/<arch>`.
This can be created using `snapcraft` or extracted from an `.snap` files using `unsquashfs`.

As an example to see the process done during the CI build, the extract is performed using this script `../.github/scripts/extract-docker-files.sh`.

Also is required to provide at least the `SNAP_CORE_YEAR` and `TARGETARCH` to build the docker image itself.
