group "default" {
	targets = ["ubuntu"]
}

variable "REPO" {
  default = "radare/radare2"
}

variable "R2_VERSION" {
	default = ""
}

variable "SNAP_CORE_YEAR" {
	default = "22"
}

target "ubuntu" {
	platforms = ["linux/amd64", "linux/arm64", "linux/arm/v7"]
	dockerfile = "Dockerfile"

	args = {
		"SNAP_CORE_YEAR" = "${SNAP_CORE_YEAR}"
		"R2_VERSION" = "${R2_VERSION}"
	}

	labels = {
		"org.opencontainers.image.title" = "radare2"
		"org.opencontainers.image.description" = "UNIX-like reverse engineering framework and command-line toolset"
		"org.opencontainers.image.ref.name" = "${REPO}"
		"org.opencontainers.image.version" = "${R2_VERSION}"
		"org.opencontainers.image.vendor" = "radareorg"
		"org.opencontainers.image.licenses" = "LGPL-3.0-only"
		"org.opencontainers.image.url" = "https://www.radare.org/"
		"org.opencontainers.image.source" = "https://github.com/radareorg/radare2-snap"
	}

	tags = [
		"${REPO}:latest",
		notequal("", R2_VERSION) ? "${REPO}:${R2_VERSION}" : ""
	]
}
