package test

import (
	"bytes"
	"fmt"
	"os/exec"
	"regexp"
	"strconv"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/docker"
	"github.com/stretchr/testify/assert"
)

// securityFloor is the first patch release that fixes CVE-2026-109618 and
// CVE-2026-109619. https://www.php.net/archive/2026.php#2026-10-21-5
var securityFloor = map[string]string{
	"8.5": "8.5.12",
	"8.4": "8.4.27",
	"8.3": "8.3.36",
	"8.2": "8.2.35",
}

// phpVersionPattern matches the version line of `php -v`, skipping any warning
// line an extension prints ahead of it.
var phpVersionPattern = regexp.MustCompile(`(?m)^PHP\s+(\d+\.\d+\.\d+)`)

func phpVersion(output string) string {
	match := phpVersionPattern.FindStringSubmatch(output)
	if match == nil {
		return ""
	}
	return match[1]
}

// atLeast reports whether version is the same as or newer than minimum.
func atLeast(version, minimum string) bool {
	actual, okActual := parseVersion(version)
	required, okRequired := parseVersion(minimum)
	if !okActual || !okRequired {
		return false
	}
	for i := range actual {
		if actual[i] != required[i] {
			return actual[i] > required[i]
		}
	}
	return true
}

func parseVersion(version string) ([3]int, bool) {
	var parsed [3]int
	parts := strings.Split(version, ".")
	if len(parts) != len(parsed) {
		return parsed, false
	}
	for i, part := range parts {
		number, err := strconv.Atoi(part)
		if err != nil {
			return parsed, false
		}
		parsed[i] = number
	}
	return parsed, true
}

func TestSmoke(t *testing.T) {
	// website::tag::1:: Configure the tag to use on the Docker image.
	tag := "docker-smoke"
	VERSION, err := exec.Command("../support/VERSION.sh").Output()
	if err == nil {
	}
	ALT_VERSION, err := exec.Command("../support/ALT_VERSION.sh").Output()
	if err == nil {
	}
	buildOptions := &docker.BuildOptions{
		Tags: []string{tag},
		BuildArgs: []string{
			fmt.Sprintf("VERSION=%s", bytes.TrimRight(VERSION, "\n")),
			fmt.Sprintf("ALT_VERSION=%s", bytes.TrimRight(ALT_VERSION, "\n")),
		},
	}

	// website::tag::2:: Build the Docker image.
	docker.Build(t, "../", buildOptions)

	// website::tag::3:: Run the Docker image.
	opts := &docker.RunOptions{Command: []string{"php", "-v"}}
	output := docker.Run(t, tag, opts)
	assert.Contains(t, output, "PHP")

	// website::tag::4:: Fail when the image ships a PHP release older than the
	// fix for CVE-2026-109618 / CVE-2026-109619. A frozen base tag keeps
	// resolving to an old patch release without any visible error.
	minor := strings.TrimSpace(string(VERSION))
	minimum, gated := securityFloor[minor]
	if !gated {
		return
	}
	version := phpVersion(output)
	if version == "" {
		t.Fatalf("could not read a PHP version from %q", output)
	}
	assert.Truef(t, atLeast(version, minimum),
		"PHP %s is below the security floor PHP %s: CVE-2026-109618 and CVE-2026-109619 are unpatched in this image",
		version, minimum)
}
