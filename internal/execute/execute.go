// Package execute is a simple package that wraps the os/exec Command features
// for convenient use in asdf. It was inspired by
// https://github.com/chen-keinan/go-command-eval
package execute

import (
	"fmt"
	"io"
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
	var command string
	if c.Expression != "" {
		// Expressions need to be invoked inside a Bash function, so variables like
		// $0 and $@ are available
		command = fmt.Sprintf("fn() { %s; }; fn %s", c.Expression, formatArgString(c.Args))
	} else {
		// Scripts can be invoked directly, with args provided
		command = fmt.Sprintf("%s %s", c.Command, formatArgString(c.Args))
	}

	cmd := exec.Command("bash", "-c", command)

	cmd.Env = mapToSlice(c.Env)
	cmd.Stdin = c.Stdin

	// Capture stdout and stderr
	cmd.Stdout = c.Stdout
	cmd.Stderr = c.Stderr

	return cmd.Run()
}

func formatArgString(args []string) string {
	var newArgs []string
	for _, str := range args {
		newArgs = append(newArgs, fmt.Sprintf("\"%s\"", str))
	}
	return strings.Join(newArgs, " ")
}

func mapToSlice(env map[string]string) (slice []string) {
	for key, value := range env {
		slice = append(slice, fmt.Sprintf("%s=%s", key, value))
	}

	return slice
}
