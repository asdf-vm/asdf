package cli

import (
	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/asdf-vm/asdf/internal/config"
)

func TestSetPath(t *testing.T) {
	originalPaths := "/dummy/bin:/example/bin"
	t.Setenv("PATH", originalPaths)

	t.Run("When ForcePrepend turned on", func(t *testing.T) {
		paths := setPath(
			config.Config{ForcePrepend: true},
			[]string{"/awesome/bin", "/cool/bin"},
		)

		assert.Equal(t, paths, "/awesome/bin:/cool/bin:"+originalPaths, "Then prepend path directories to the front-most part of PATH env")
	})

	t.Run("When ForcePrepend turned off", func(t *testing.T) {
		paths := setPath(
			config.Config{ForcePrepend: false},
			[]string{"/awesome/bin", "/cool/bin"},
		)

		assert.Equal(t, paths, originalPaths+":/awesome/bin:/cool/bin", "Then append path directories to the hinder-most part of PATH env")
	})
}
