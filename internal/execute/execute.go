// Package execute is a simple package that wraps the os/exec Command features
// for convenient use in asdf. It was inspired by
// https://github.com/chen-keinan/go-command-eval
package execute

import (
	"fmt"
	"io"
	"os"
	"os/exec"
	"strings"
)

// Command represents a Bash command that can be executed by asdf
type Command struct {
	Command    string
	Expression string
	Args       []string
	Stdin      io.Reader
	Stdout     io.Writer
	Stderr     io.Writer
	Env        map[string]string
}

// New takes a string containing the path to a Bash script, and a slice of
// string arguments and returns a Command struct
func New(command string, args []string) Command {
	return Command{Command: command, Args: args}
}

// NewExpression takes a string containing a Bash expression and a slice of
// string arguments and returns a Command struct
func NewExpression(expression string, args []string) Command {
	return Command{Expression: expression, Args: args}
}

// Run executes a Command with Bash and returns the error if there is one
func (c Command) Run() error {
	var bashArgs []string

	if c.Expression != "" {
		script := fmt.Sprintf(`fn() { %s; }; fn "$@"`, c.Expression)
		bashArgs = append([]string{"-c", script, "asdf"}, c.Args...)
	} else if len(c.Args) > 0 {
		bashArgs = append([]string{"-c", `exec "$0" "$@"`, c.Command}, c.Args...)
	} else {
		bashArgs = []string{"-c", c.Command}
	}

	cmd := exec.Command("bash", bashArgs...)

	if len(c.Env) > 0 {
		cmd.Env = MergeWithCurrentEnv(c.Env)
	} else {
		cmd.Env = os.Environ()
	}

	cmd.Stdin = c.Stdin
	cmd.Stdout = c.Stdout
	cmd.Stderr = c.Stderr

	return cmd.Run()
}

// MergeWithCurrentEnv merges the provided map into the current environment variables
func MergeWithCurrentEnv(env map[string]string) (slice []string) {
	return MapToSlice(MergeEnv(CurrentEnv(), env))
}

// CurrentEnv returns the current environment as a map
func CurrentEnv() map[string]string {
	return SliceToMap(os.Environ())
}

// MergeEnv takes two maps with string keys and values and merges them.
func MergeEnv(map1, map2 map[string]string) map[string]string {
	for key, value := range map2 {
		map1[key] = value
	}

	return map1
}

// MapToSlice converts an env map to env slice suitable for syscall.Exec
func MapToSlice(env map[string]string) (slice []string) {
	for key, value := range env {
		slice = append(slice, fmt.Sprintf("%s=%s", key, value))
	}

	return slice
}

// SliceToMap converts an env map to env slice suitable for syscall.Exec
func SliceToMap(env []string) map[string]string {
	envMap := map[string]string{}

	for _, envVar := range env {
		varValue := strings.SplitN(envVar, "=", 2)

		if len(varValue) == 2 {
			envMap[varValue[0]] = varValue[1]
		}
	}

	return envMap
}
