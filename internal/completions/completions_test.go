package completions

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestGet(t *testing.T) {
	t.Run("returns file when completion file found with matching name", func(t *testing.T) {
		file, found := Get("bash")

		info, err := file.Stat()
		assert.Nil(t, err)
		assert.Equal(t, "asdf.bash", info.Name())

		assert.True(t, found)
	})

	t.Run("returns false when completion file not found", func(t *testing.T) {
		_, found := Get("non-existent")
		assert.False(t, found)
	})
}

func TestNames(t *testing.T) {
	t.Run("returns slice of shell names for which completion is available", func(t *testing.T) {
		assert.Equal(t, []string{"bash", "elvish", "fish", "nushell", "zsh"}, Names())
	})
}
