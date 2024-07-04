package execute

import (
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
		assert.Equal(t, "sh is /bin/sh\n", stdout.String())
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
		assert.Equal(t, "sh is /bin/sh\n", stdout.String())
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
