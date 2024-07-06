// Package hook provides a simple interface for running hook commands that may
// be defined in the asdfrc file
package hook

import (
	"os"

	"asdf/config"
	"asdf/execute"
)

// Run gets a hook command from config and runs it with the provided arguments
func Run(config config.Config, hookName string, arguments []string) error {
	hookCmd, err := config.GetHook(hookName)
	if err != nil {
		return err
	}

	if hookCmd == "" {
		return nil
	}

	cmd := execute.NewExpression(hookCmd, arguments)

	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	return cmd.Run()
}
