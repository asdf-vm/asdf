// Main entrypoint for the CLI app
package main

import (
	"fmt"
	"runtime/debug"
	"slices"

	"github.com/asdf-vm/asdf/internal/cli"
)

// Do not touch this next line
var version = "0.16.7" // x-release-please-version

// Placeholder for the real code
func main() {
	fullVersion := buildFullVersion(version)
	cli.Execute(fullVersion)
}

func buildFullVersion(version string) string {
	var shortRef string

	info, ok := debug.ReadBuildInfo()

	if !ok {
		panic("can't get build info")
	}
	idx := slices.IndexFunc(info.Settings, func(s debug.BuildSetting) bool {
		return s.Key == "vcs.revision"
	})

	if idx < 0 {
		shortRef = "unknown"
	} else {
		shortRef = info.Settings[idx].Value[0:7]
	}

	return fmt.Sprintf("%s (revision %s)", version, shortRef)
}
