package execute

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestNew(t *testing.T) {
	t.Run("Returns new command", func(t *testing.T) {
		cmd := New("echo", []string{"test string"})
		assert.Equal(t, "echo", cmd.Command)
		assert.Equal(t, "", cmd.Expression)
	})
}

func TestNewExpression(t *testing.T) {
	t.Run("Returns new command expression", func(t *testing.T) {
		cmd := NewExpression("echo", []string{"test string"})
		assert.Equal(t, "echo", cmd.Expression)
		assert.Equal(t, "", cmd.Command)
	})
}

func TestRun_Command(t *testing.T) {
	t.Run("command is executed with bash", func(t *testing.T) {
		cmd := New("echo $(type -a sh);", []string{})

		var stdout strings.Builder
		cmd.Stdout = &stdout
		err := cmd.Run()

		assert.Nil(t, err)
		assert.Contains(t, stdout.String(), "sh is /")
	})

	t.Run("positional arg is passed to command", func(t *testing.T) {
		cmd := New("testdata/script", []string{"test string"})

		var stdout strings.Builder
		cmd.Stdout = &stdout
		err := cmd.Run()

		assert.Nil(t, err)
		assert.Equal(t, "test string\n", stdout.String())
	})

	t.Run("positional args are passed to command", func(t *testing.T) {
		cmd := New("testdata/script", []string{"test string", "another string"})

		var stdout strings.Builder
		cmd.Stdout = &stdout
		err := cmd.Run()

		assert.Nil(t, err)
		assert.Equal(t, "test string another string\n", stdout.String())
	})

	t.Run("environment variables are passed to command", func(t *testing.T) {
		cmd := New("echo $MYVAR;", []string{})
		cmd.Env = map[string]string{"MYVAR": "my var value"}

		var stdout strings.Builder
		cmd.Stdout = &stdout
		err := cmd.Run()

		assert.Nil(t, err)
		assert.Equal(t, "my var value\n", stdout.String())
	})

	t.Run("system environment variables are passed to command", func(t *testing.T) {
		cmd := New("echo $MYVAR1;", []string{})
		err := os.Setenv("MYVAR1", "my var value")
		assert.Nil(t, err)

		var stdout strings.Builder
		cmd.Stdout = &stdout
		err = cmd.Run()

		assert.Nil(t, err)
		assert.Equal(t, "my var value\n", stdout.String())
	})

	t.Run("provided env overwrites system environment variables when passed to command", func(t *testing.T) {
		cmd := New("echo $MYVAR2;", []string{})
		err := os.Setenv("MYVAR2", "should be dropped")
		assert.Nil(t, err)

		var stdout strings.Builder
		cmd.Stdout = &stdout
		cmd.Env = map[string]string{"MYVAR2": "final value"}
		err = cmd.Run()

		assert.Nil(t, err)
		assert.Equal(t, "final value\n", stdout.String())
	})

	t.Run("captures stdout and stdin", func(t *testing.T) {
		cmd := New("echo 'a test' | tee /dev/stderr", []string{})
		cmd.Env = map[string]string{"MYVAR": "my var value"}

		var stdout strings.Builder
		cmd.Stdout = &stdout
		var stderr strings.Builder
		cmd.Stderr = &stderr

		err := cmd.Run()

		assert.Nil(t, err)
		assert.Equal(t, "a test\n", stdout.String())
		assert.Equal(t, "a test\n", stderr.String())
	})

	t.Run("returns error when non-zero exit code", func(t *testing.T) {
		cmd := New("exit 12", []string{})

		var stdout strings.Builder
		cmd.Stdout = &stdout
		err := cmd.Run()

		assert.NotNil(t, err)
		assert.Equal(t, "", stdout.String())
		assert.Equal(t, 12, err.(*exec.ExitError).ExitCode())
	})
}

func TestRun_Expression(t *testing.T) {
	t.Run("expression is executed with bash", func(t *testing.T) {
		cmd := NewExpression("echo $(type -a sh)", []string{})

		var stdout strings.Builder
		cmd.Stdout = &stdout
		err := cmd.Run()

		assert.Nil(t, err)
		assert.Contains(t, stdout.String(), "sh is /")
	})

	t.Run("positional arg is passed to expression", func(t *testing.T) {
		cmd := NewExpression("echo $1; true", []string{"test string"})

		var stdout strings.Builder
		cmd.Stdout = &stdout
		err := cmd.Run()

		assert.Nil(t, err)
		assert.Equal(t, "test string\n", stdout.String())
	})

	t.Run("positional args are passed to expression", func(t *testing.T) {
		cmd := NewExpression("echo $@; true", []string{"test string", "another string"})

		var stdout strings.Builder
		cmd.Stdout = &stdout
		err := cmd.Run()

		assert.Nil(t, err)
		assert.Equal(t, "test string another string\n", stdout.String())
	})

	t.Run("environment variables are passed to expression", func(t *testing.T) {
		cmd := NewExpression("echo $MYVAR", []string{})
		cmd.Env = map[string]string{"MYVAR": "my var value"}

		var stdout strings.Builder
		cmd.Stdout = &stdout
		err := cmd.Run()

		assert.Nil(t, err)
		assert.Equal(t, "my var value\n", stdout.String())
	})

	t.Run("captures stdout and stdin", func(t *testing.T) {
		cmd := NewExpression("echo 'a test' | tee /dev/stderr", []string{})
		cmd.Env = map[string]string{"MYVAR": "my var value"}

		var stdout strings.Builder
		cmd.Stdout = &stdout
		var stderr strings.Builder
		cmd.Stderr = &stderr

		err := cmd.Run()

		assert.Nil(t, err)
		assert.Equal(t, "a test\n", stdout.String())
		assert.Equal(t, "a test\n", stderr.String())
	})

	t.Run("returns error when non-zero exit code", func(t *testing.T) {
		cmd := NewExpression("exit 12", []string{})

		var stdout strings.Builder
		cmd.Stdout = &stdout
		err := cmd.Run()

		assert.NotNil(t, err)
		assert.Equal(t, "", stdout.String())
		assert.Equal(t, 12, err.(*exec.ExitError).ExitCode())
	})
}

func TestMergeWithCurrentEnv(t *testing.T) {
	t.Run("merge with current env", func(t *testing.T) {
		path := os.Getenv("PATH")
		assert.NotEmpty(t, path)

		newEnv := map[string]string{"PATH": "new_path"}
		mergedEnv := MergeWithCurrentEnv(newEnv)
		assert.Contains(t, mergedEnv, "PATH=new_path")
		assert.NotContains(t, mergedEnv, "PATH="+path)
	})
}

func TestCurrentEnv(t *testing.T) {
	t.Run("returns map of current environment", func(t *testing.T) {
		envMap := CurrentEnv()
		path, found := envMap["PATH"]
		assert.True(t, found)
		assert.NotEmpty(t, path)
	})
}

func TestMergeEnv(t *testing.T) {
	t.Run("merges two maps", func(t *testing.T) {
		map1 := map[string]string{"Key": "value"}
		map2 := map[string]string{"Key2": "value2"}
		map3 := MergeEnv(map1, map2)
		assert.Equal(t, map3["Key"], "value")
		assert.Equal(t, map3["Key2"], "value2")
	})

	t.Run("doesn't change original map", func(t *testing.T) {
		map1 := map[string]string{"Key": "value"}
		map2 := map[string]string{"Key2": "value2"}
		_ = MergeEnv(map1, map2)
		assert.Equal(t, map1["Key2"], "value2")
	})

	t.Run("second map overwrites values in first", func(t *testing.T) {
		map1 := map[string]string{"Key": "value"}
		map2 := map[string]string{"Key": "value2"}
		map3 := MergeEnv(map1, map2)
		assert.Equal(t, map3["Key"], "value2")
	})
}

func TestSliceToMap(t *testing.T) {
	tests := []struct {
		input  []string
		output map[string]string
	}{
		{
			input:  []string{"VAR=value"},
			output: map[string]string{"VAR": "value"},
		},
		{
			input:  []string{"BASH_FUNC_bats_readlinkf%%=() {  readlink -f \"$1\"\n}"},
			output: map[string]string{"BASH_FUNC_bats_readlinkf%%": "() {  readlink -f \"$1\"\n}"},
		},
		{
			input:  []string{"MYVAR=some things = with = in it"},
			output: map[string]string{"MYVAR": "some things = with = in it"},
		},
		{
			input:  []string{"MYVAR=value\nwith\nnewlines"},
			output: map[string]string{"MYVAR": "value\nwith\nnewlines"},
		},
		{
			input:  []string{"MYVAR=value", "with", "newlines"},
			output: map[string]string{"MYVAR": "value\nwith\nnewlines"},
		},
	}

	for _, tt := range tests {
		t.Run(fmt.Sprintf("input: %s, output: %s", tt.input, tt.output), func(t *testing.T) {
			assert.Equal(t, tt.output, SliceToMap(tt.input))
		})
	}
}
