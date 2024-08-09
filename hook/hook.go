// Package hook provides a simple interface for running hook commands that may
// be defined in the asdfrc file
package hook

import (
	"io"
	"os"

	"asdf/config"
	"asdf/execute"
)

// Run gets a hook command from config and runs it with the provided arguments.
// Output is sent to STDOUT and STDERR
func Run(conf config.Config, hookName string, arguments []string) error {
	return RunWithOutput(conf, hookName, arguments, os.Stdout, os.Stderr)
}

// RunWithOutput gets a hook command from config and runs it with the provided
// arguments. Output is sent to the provided io.Writers.
func RunWithOutput(config config.Config, hookName string, arguments []string, stdOut io.Writer, stdErr io.Writer) error {
	hookCmd, err := config.GetHook(hookName)
	if err != nil {
		return err
	}

	if hookCmd == "" {
		return nil
	}

	cmd := execute.NewExpression(hookCmd, arguments)

	cmd.Stdout = stdOut
	cmd.Stderr = stdErr

	return cmd.Run()
}
