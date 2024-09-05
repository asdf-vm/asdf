package hook

import (
	"os/exec"
	"testing"

	"asdf/internal/config"

	"github.com/stretchr/testify/assert"
)

func TestRun(t *testing.T) {
	// Set the asdf config file location to the test file
	t.Setenv("ASDF_CONFIG_FILE", "testdata/asdfrc")

	t.Run("accepts config, hook name, and a slice of string arguments", func(t *testing.T) {
		config, err := config.LoadConfig()
		assert.Nil(t, err)

		err = Run(config, "pre_asdf_plugin_add_test", []string{})
		assert.Nil(t, err)
	})

	t.Run("passes argument to command", func(t *testing.T) {
		config, err := config.LoadConfig()
		assert.Nil(t, err)

		err = Run(config, "pre_asdf_plugin_add_test2", []string{"123"})
		assert.Equal(t, 123, err.(*exec.ExitError).ExitCode())
	})

	t.Run("passes arguments to command", func(t *testing.T) {
		config, err := config.LoadConfig()
		assert.Nil(t, err)

		err = Run(config, "pre_asdf_plugin_add_test3", []string{"exit 123"})
		assert.Equal(t, 123, err.(*exec.ExitError).ExitCode())
	})

	t.Run("does not return error when no such hook is defined in asdfrc", func(t *testing.T) {
		config, err := config.LoadConfig()
		assert.Nil(t, err)

		err = Run(config, "nonexistant-hook", []string{})
		assert.Nil(t, err)
	})
}
