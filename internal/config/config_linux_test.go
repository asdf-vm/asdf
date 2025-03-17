//go:build linux

package config

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestLoadConfigEnv_WithForcePrependEnv_OnLinux(t *testing.T) {
	t.Run("When ASDF_FORCE_PREPEND env does not given on Linux", func(t *testing.T) {
		config, _ := loadConfigEnv()

		assert.False(t, config.ForcePrepend, "Then ForcePrepend property is false")
	})
}
