package completions

import (
	"os/exec"
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

func TestZshCompletionCandidates(t *testing.T) {
	zsh, err := exec.LookPath("zsh")
	if err != nil {
		t.Skip("zsh is not installed")
	}

	t.Run("completes top-level commands", func(t *testing.T) {
		candidates := runZshCompletion(t, zsh, "asdf", "")

		for _, candidate := range []string{"plugin", "install", "list", "set"} {
			assert.Contains(t, candidates, candidate)
		}
	})

	t.Run("completes plugin subcommands", func(t *testing.T) {
		candidates := runZshCompletion(t, zsh, "asdf", "plugin", "")

		assert.Equal(t, []string{"add", "list", "remove", "update"}, candidates)
	})
}

func runZshCompletion(t *testing.T, zsh string, words ...string) []string {
	t.Helper()

	completion, found := Get("zsh")
	if !found {
		t.Fatal("zsh completion file not found")
	}
	defer func() {
		assert.NoError(t, completion.Close())
	}()

	// Stub the Zsh completion system so candidates can be captured without an
	// interactive shell while the asdf completion function itself runs unchanged.
	const script = `
_arguments() {
  state=command
}
_describe() {
  local values_name=$4
  local -a values
  values=("${(@P)values_name}")
  print -l -- "${values[@]%%:*}"
}
_asdf() {
  source /dev/stdin
}
words=("$@")
CURRENT=${#words}
_asdf
`

	args := []string{"-f", "-c", script, "asdf-completion-test"}
	args = append(args, words...)
	command := exec.Command(zsh, args...)
	command.Stdin = completion
	output, err := command.CombinedOutput()
	if err != nil {
		t.Fatalf("running zsh completion: %v\n%s", err, output)
	}
	return strings.Fields(string(output))
}
