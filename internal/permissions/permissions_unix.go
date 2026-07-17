//go:build !windows
// +build !windows

// Package permissions provides platform-specific file permission code
package permissions

import "syscall"

// FileExecutable checks if a file is executable
func FileExecutable(path string) error {
	return syscall.Access(path, 0x1)
}
