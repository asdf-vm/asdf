// Main entrypoint for the CLI app
package main

import (
	"runtime/debug"

	"github.com/asdf-vm/asdf/internal/cli"
)

// Replaced with the real version during a typical build
var version = ""

func getVersion() string {
	if version != "" {
		return version
	}

	info, ok := debug.ReadBuildInfo()
	if ok {
		return info.Main.Version
	}

	return "unknown"
}

// Placeholder for the real code
func main() {
	cli.Execute(getVersion())
}
