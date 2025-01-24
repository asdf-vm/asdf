// Package execenv contains logic for generating execution environing using a plugin's
// exec-env callback script if available.
package execenv

import (
	"fmt"
	"os"
	"strings"

	"github.com/asdf-vm/asdf/internal/execute"
	"github.com/asdf-vm/asdf/internal/plugins"
)

const execEnvCallbackName = "exec-env"

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
	expression := execute.NewExpression(fmt.Sprintf(". \"%s\"; env", execEnvPath), []string{})
	expression.Env = callbackEnv
	expression.Stdout = &stdout
	err = expression.Run()

	return envMap(stdout.String()), err
}

func envMap(env string) map[string]string {
	slice := map[string]string{}

	for _, envVar := range strings.Split(env, "\n") {
		varValue := strings.Split(envVar, "=")
		if len(varValue) == 2 {
			slice[varValue[0]] = varValue[1]
		}
	}

	return slice
}

// SliceToMap converts an env map to env slice suitable for syscall.Exec
func SliceToMap(env []string) map[string]string {
	envMap := map[string]string{}

	for _, envVar := range env {
		varValue := strings.Split(envVar, "=")
		if len(varValue) == 2 {
			envMap[varValue[0]] = varValue[1]
		}
	}

	return envMap
}
