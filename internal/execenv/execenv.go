// Package execenv contains logic for generating execution environing using a plugin's
// exec-env callback script if available.
package execenv

import (
	"fmt"
	"os"

	"github.com/asdf-vm/asdf/internal/exec"
	"github.com/asdf-vm/asdf/internal/shims"
	"github.com/asdf-vm/asdf/internal/toolversions"

	"github.com/asdf-vm/asdf/internal/execute"
	"github.com/asdf-vm/asdf/internal/plugins"
)

const execEnvCallbackName = "exec-env"

func Invoke(plugin plugins.Plugin, parsedVersion toolversions.Version, env map[string]string, command string, args []string) (err error) {
	execEnvPath := ""

	if parsedVersion.Type != "system" {
		envPath, err := plugin.CallbackPath(execEnvCallbackName)
		if _, ok := err.(plugins.NoCallbackError); !ok && err != nil {
			return err
		}
		execEnvPath = envPath
	}

	if execEnvPath != "" {
		// This is done to support the legacy behavior. exec-env is the only asdf
		// callback that works by exporting environment variables. Because of this,
		// executing the callback isn't enough. We actually need to source it (.) so
		// the environment variables get set, before running the command.
		script := "set -e; . '" + execEnvPath + "'; exec '" + command + "' $@;"
		cmd := execute.NewExpression(script, args)
		cmd.Env = env
		return cmd.Run()
	} else {
		fname, err := shims.ExecutableOnPath(env["PATH"], command)
		if err != nil {
			return err
		}

		finalEnv := append(os.Environ(), execute.MapToSlice(env)...)
		err = exec.Exec(fname, args, finalEnv)
		if err != nil {
			fmt.Printf("err %#+v\n", err.Error())
		}
		return err
	}
}
