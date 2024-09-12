package paths

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestRemoveFromPath(t *testing.T) {
	t.Run("returns PATH string with matching path removed", func(t *testing.T) {
		got := RemoveFromPath("/foo/bar:/baz/bim:/home/user/bin", "/baz/bim")
		assert.Equal(t, got, "/foo/bar:/home/user/bin")
	})

	t.Run("returns PATH string unchanged when no matching path found", func(t *testing.T) {
		got := RemoveFromPath("/foo/bar:/baz/bim:/home/user/bin", "/path-not-present/")
		assert.Equal(t, got, "/foo/bar:/baz/bim:/home/user/bin")
	})
}
