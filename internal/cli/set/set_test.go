package set

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestAll(t *testing.T) {
	homeFunc := func() (string, error) {
		return "", nil
	}

	t.Run("prints error when no arguments specified", func(t *testing.T) {
		stdout, stderr := buildOutputs()
		err := Main(&stdout, &stderr, []string{}, false, false, homeFunc)

		assert.Error(t, err, "tool and version must be provided as arguments")
		assert.Equal(t, stdout.String(), "")
		assert.Equal(t, stderr.String(), "tool and version must be provided as arguments")
	})

	t.Run("prints error when no version specified", func(t *testing.T) {
		stdout, stderr := buildOutputs()
		err := Main(&stdout, &stderr, []string{"lua"}, false, false, homeFunc)

		assert.Error(t, err, "version must be provided as an argument")
		assert.Equal(t, stdout.String(), "")
		assert.Equal(t, stderr.String(), "version must be provided as an argument")
	})

	t.Run("prints error when both --parent and --home flags are set", func(t *testing.T) {
		stdout, stderr := buildOutputs()
		err := Main(&stdout, &stderr, []string{"lua", "5.2.3"}, true, true, homeFunc)

		assert.Error(t, err, "home and parent flags cannot both be specified; must be one location or the other")
		assert.Equal(t, stdout.String(), "")
		assert.Equal(t, stderr.String(), "home and parent flags cannot both be specified; must be one location or the other")
	})

	t.Run("sets version in current directory when no flags provided", func(t *testing.T) {
		stdout, stderr := buildOutputs()
		dir := t.TempDir()
		assert.Nil(t, os.Chdir(dir))

		err := Main(&stdout, &stderr, []string{"lua", "5.2.3"}, false, false, homeFunc)

		assert.Nil(t, err)
		assert.Equal(t, stdout.String(), "")
		assert.Equal(t, stderr.String(), "")

		path := filepath.Join(dir, ".tool-versions")
		bytes, err := os.ReadFile(path)
		assert.Nil(t, err)
		assert.Equal(t, "lua 5.2.3\n", string(bytes))
	})

	t.Run("sets version in parent directory when --parent flag provided", func(t *testing.T) {
		stdout, stderr := buildOutputs()
		dir := t.TempDir()
		subdir := filepath.Join(dir, "subdir")
		assert.Nil(t, os.Mkdir(subdir, 0o777))
		assert.Nil(t, os.Chdir(subdir))
		assert.Nil(t, os.WriteFile(filepath.Join(dir, ".tool-versions"), []byte("lua 4.0.0"), 0o666))

		err := Main(&stdout, &stderr, []string{"lua", "5.2.3"}, false, true, homeFunc)

		assert.Nil(t, err)
		assert.Equal(t, stdout.String(), "")
		assert.Equal(t, stderr.String(), "")

		path := filepath.Join(dir, ".tool-versions")
		bytes, err := os.ReadFile(path)
		assert.Nil(t, err)
		assert.Equal(t, "lua 5.2.3\n", string(bytes))
	})

	t.Run("sets version in home directory when --home flag provided", func(t *testing.T) {
		stdout, stderr := buildOutputs()
		homedir := filepath.Join(t.TempDir(), "home")
		assert.Nil(t, os.Mkdir(homedir, 0o777))
		err := Main(&stdout, &stderr, []string{"lua", "5.2.3"}, true, false, func() (string, error) {
			return homedir, nil
		})

		assert.Nil(t, err)
		assert.Equal(t, stdout.String(), "")
		assert.Equal(t, stderr.String(), "")

		path := filepath.Join(homedir, ".tool-versions")
		bytes, err := os.ReadFile(path)
		assert.Nil(t, err)
		assert.Equal(t, "lua 5.2.3\n", string(bytes))
	})

	t.Run("sets version in current directory only once", func(t *testing.T) {
		stdout, stderr := buildOutputs()
		dir := t.TempDir()
		assert.Nil(t, os.Chdir(dir))

		_ = Main(&stdout, &stderr, []string{"lua", "5.2.3"}, false, false, homeFunc)
		err := Main(&stdout, &stderr, []string{"lua", "5.2.3"}, false, false, homeFunc)

		assert.Nil(t, err)
		assert.Equal(t, stdout.String(), "")
		assert.Equal(t, stderr.String(), "")

		path := filepath.Join(dir, ".tool-versions")
		bytes, err := os.ReadFile(path)
		assert.Nil(t, err)
		assert.Equal(t, "lua 5.2.3\n", string(bytes))
	})
}

func buildOutputs() (strings.Builder, strings.Builder) {
	var stdout strings.Builder
	var stderr strings.Builder

	return stdout, stderr
}
