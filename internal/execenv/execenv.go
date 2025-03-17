// Package execenv contains logic for generating execution environing using a plugin's
// exec-env callback script if available.
package execenv

import (
	"fmt"
	"strings"

	"github.com/asdf-vm/asdf/internal/execute"
	"github.com/asdf-vm/asdf/internal/plugins"
)

const execEnvCallbackName = "exec-env"

// Generate runs exec-env callback if available and captures the environment
// variables it sets. It then parses them and returns them as a map.
func Generate(plugin plugins.Plugin, callbackEnv map[string]string) (env map[string]string, err error) {
	execEnvPath, err := plugin.CallbackPath(execEnvCallbackName)
	if err != nil {
		return callbackEnv, err
	}

	var stdout strings.Builder

	// This is done to support the legacy behavior. exec-env is the only asdf
	// callback that works by exporting environment variables. Because of this,
	// executing the callback isn't enough. We actually need to source it (.) so
	// the environment variables get set, and then run `env` so they get printed
	// to STDOUT.
	expression := execute.NewExpression(fmt.Sprintf(". \"%s\"; env -0", execEnvPath), []string{})
	expression.Env = callbackEnv
	expression.Stdout = &stdout
	err = expression.Run()

	str := stdout.String()
	return execute.SliceToMap(strings.Split(str, "\x00")), err
}
