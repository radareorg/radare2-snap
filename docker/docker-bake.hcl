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
		"IMAGEREFNAME" = "${REPO}"
		"R2_VERSION" = "${R2_VERSION}"
	}

	tags = [
		"${REPO}:latest",
		notequal("", R2_VERSION) ? "${REPO}:${R2_VERSION}" : ""
	]
}
