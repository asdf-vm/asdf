package completions

import (
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
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

// Stands in for the asdf binary while testing the Nushell completion code. It
// prints the same columns as the plugin list command in internal/cli.
const nushellAsdfStub = `#!/usr/bin/env bash
if [ "$1" != "plugin" ] || [ "$2" != "list" ]; then
  exit 1
fi
shift 2
urls=""
refs=""
for arg in "$@"; do
  case "$arg" in
  --urls) urls="yes" ;;
  --refs) refs="yes" ;;
  esac
done
print_plugin() {
  if [ -n "$urls" ] && [ -n "$refs" ]; then
    printf "%s\t\t%s\t%s\n" "$1" "$2" "$3"
  elif [ -n "$refs" ]; then
    printf "%s\t\t%s\n" "$1" "$3"
  elif [ -n "$urls" ]; then
    printf "%s\t\t%s\n" "$1" "$2"
  else
    printf "%s\n" "$1"
  fi
}
print_plugin act https://github.com/gr1m0h/asdf-act.git 5b6a14e63a1a3a5a8a7a9d5f6bbd14e7ab4f1f2c
print_plugin age https://github.com/threkk/asdf-age d84e2b4864fcec5733fa22c7389c9f2b09324dae
`

func TestNushellPluginList(t *testing.T) {
	if _, err := exec.LookPath("nu"); err != nil {
		t.Skip("Nu is not installed")
	}

	dir := t.TempDir()

	file, found := Get("nushell")
	assert.True(t, found)
	code, err := io.ReadAll(file)
	assert.Nil(t, err)

	completionPath := filepath.Join(dir, "asdf.nu")
	assert.Nil(t, os.WriteFile(completionPath, code, 0o644))

	binDir := filepath.Join(dir, "bin")
	assert.Nil(t, os.Mkdir(binDir, 0o755))
	assert.Nil(t, os.WriteFile(filepath.Join(binDir, "asdf"), []byte(nushellAsdfStub), 0o755))

	tests := []struct {
		name    string
		command string
		want    string
	}{
		{
			name:    "lists plugin names",
			command: "asdf plugin list | to csv -n",
			want:    "act\nage",
		},
		{
			name:    "lists urls, including urls not ending in .git",
			command: "asdf plugin list --urls | to csv -n",
			want: "act,https://github.com/gr1m0h/asdf-act.git\n" +
				"age,https://github.com/threkk/asdf-age",
		},
		{
			name:    "lists refs",
			command: "asdf plugin list --refs | to csv -n",
			want: "act,5b6a14e63a1a3a5a8a7a9d5f6bbd14e7ab4f1f2c\n" +
				"age,d84e2b4864fcec5733fa22c7389c9f2b09324dae",
		},
		{
			name:    "lists urls and refs",
			command: "asdf plugin list --urls --refs | to csv -n",
			want: "act,https://github.com/gr1m0h/asdf-act.git,5b6a14e63a1a3a5a8a7a9d5f6bbd14e7ab4f1f2c\n" +
				"age,https://github.com/threkk/asdf-age,d84e2b4864fcec5733fa22c7389c9f2b09324dae",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			script := fmt.Sprintf("source %s\n%s", completionPath, tt.command)
			cmd := exec.Command("nu", "--no-config-file", "-c", script)
			cmd.Env = envWithPathPrefix(binDir)

			output, err := cmd.CombinedOutput()
			assert.Nil(t, err, string(output))
			assert.Equal(t, tt.want, strings.TrimSpace(string(output)))
		})
	}
}

// Returns the current environment with dir placed at the front of PATH.
func envWithPathPrefix(dir string) []string {
	env := []string{}
	for _, entry := range os.Environ() {
		if !strings.HasPrefix(entry, "PATH=") {
			env = append(env, entry)
		}
	}

	return append(env, "PATH="+dir+string(os.PathListSeparator)+os.Getenv("PATH"))
}
