// Package paths contains a variety of helper functions responsible for
// computing paths to various things. This package should not depend on any
// other asdf packages.
package paths

import (
	"path/filepath"
	"strings"
)

// RemoveFromPath returns the PATH without asdf shims path
func RemoveFromPath(currentPath, pathToRemove string) string {
	var newPaths []string

	for _, fspath := range filepath.SplitList(currentPath) {
		if fspath != pathToRemove {
			newPaths = append(newPaths, fspath)
		}
	}

	return strings.Join(newPaths, string(filepath.ListSeparator))
}
