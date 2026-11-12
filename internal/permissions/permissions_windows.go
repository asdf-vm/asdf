//go:build windows
// +build windows

// Package permissions provides platform-specific file permission code
package permissions

func FileExecutable(path string) error {
	return nil
}
