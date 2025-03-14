//go:build darwin

package config

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestLoadConfigEnv_WithForcePrependEnv_OnDarwin(t *testing.T) {
	t.Run("When ASDF_FORCE_PREPEND env does not given on macOS", func(t *testing.T) {
		config, _ := loadConfigEnv()

		assert.True(t, config.ForcePrepend, "Then ForcePrepend property is true")
	})
}
