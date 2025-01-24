// Package exec handles replacing the asdf go process with
package exec

import (
	"syscall"
)

// Exec invokes syscall.Exec to exec an executable. Requires an absolute path to
// executable.
func Exec(executablePath string, args []string, env []string) error {
	return syscall.Exec(executablePath, append([]string{executablePath}, args...), env)
}
