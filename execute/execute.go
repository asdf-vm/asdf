// Package execute is a simple package that wraps the os/exec Command features
// for convenient use in asdf. It was inspired by
// https://github.com/chen-keinan/go-command-eval
package execute

import (
	"fmt"
	"io"
	"os/exec"
)

// Command represents a Bash command that can be executed by asdf
type Command struct {
	Command string
	Args    []string
	Stdin   io.Reader
	Stdout  io.Writer
	Stderr  io.Writer
	Env     map[string]string
}

// New takes a string containing a Bash expression and a slice of string
// arguments and returns a Command struct
func New(command string, args []string) Command {
	return Command{Command: command, Args: args}
}

// Run executes a Command with Bash and returns the error if there is one
func (c Command) Run() error {
	args := append([]string{"-c", c.Command}, c.Args...)
	cmd := exec.Command("bash", args...)

	cmd.Env = mapToSlice(c.Env)
	cmd.Stdin = c.Stdin

	// Capture stdout and stderr
	cmd.Stdout = c.Stdout
	cmd.Stderr = c.Stderr

	return cmd.Run()
}

func mapToSlice(env map[string]string) (slice []string) {
	for key, value := range env {
		slice = append(slice, fmt.Sprintf("%s=%s", key, value))
	}

	return slice
}
