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
	// var command string
	var finalArgs []string

	if c.Expression != "" {
		// Expressions need to be invoked as a script to Bash, so variables like
		// $0 and $@ are available
		finalArgs = []string{"-s"}
		c.Stdin = strings.NewReader(c.Expression)
	} else {
		// Scripts can be invoked directly, with args provided
		finalArgs = []string{c.Command}
	}

	finalArgs = append(finalArgs, c.Args...)
	cmd := exec.Command("bash", finalArgs...)

	cmd.Env = append(os.Environ(), MapToSlice(c.Env)...)
	cmd.Stdin = c.Stdin

	// Capture stdout and stderr
	cmd.Stdout = c.Stdout
	cmd.Stderr = c.Stderr

	return cmd.Run()
}

// MapToSlice converts an env map to env slice suitable for syscall.Exec
func MapToSlice(env map[string]string) (slice []string) {
	for key, value := range env {
		slice = append(slice, fmt.Sprintf("%s=%s", key, value))
	}

	return slice
}

func formatArgString(args []string) string {
	var newArgs []string
	for _, str := range args {
		newArgs = append(newArgs, fmt.Sprintf("\"%s\"", str))
	}
	return strings.Join(newArgs, " ")
}
