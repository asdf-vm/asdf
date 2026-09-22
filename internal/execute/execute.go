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
	var cmd *exec.Cmd

	if c.Expression != "" {
		// Expresiones bash: fn wrapper para que $0/$@ estén disponibles
		script := fmt.Sprintf(`fn() { %s; }; fn "$@"`, c.Expression)
		args := append([]string{"-c", script, "asdf"}, c.Args...)
		cmd = exec.Command("bash", args...)

	} else if isShellExpression(c.Command) || len(c.Args) == 0 {
		command := c.Command
		if len(c.Args) > 0 {
			command = fmt.Sprintf("%s %s", c.Command, formatArgString(c.Args))
		}
		cmd = exec.Command("bash", "-c", command)

	} else {
    binary := strings.Trim(c.Command, "'\"")
    args := append([]string{"-c", `exec "$0" "$@"`, binary}, c.Args...)
    cmd = exec.Command("bash", args...)
	}

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

// isShellExpression detecta si el comando contiene metacaracteres de shell
func isShellExpression(command string) bool {
	return strings.ContainsAny(command, "$|;&`(){}[]<>\\")
}

// formatArgString wraps each argument in double quotes
func formatArgString(args []string) string {
	result := []string{}
	for _, arg := range args {
		result = append(result, fmt.Sprintf(`"%s"`, arg))
	}
	return strings.Join(result, " ")
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

// SliceToMap converts an env slice to env map
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