package info

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"asdf/internal/config"

	"github.com/stretchr/testify/assert"
)

func TestWrite(t *testing.T) {
	testDataDir := t.TempDir()
	err := os.MkdirAll(filepath.Join(testDataDir, "plugins"), 0o777)
	assert.Nil(t, err)

	conf := config.Config{DataDir: testDataDir}
	var stdout strings.Builder

	err = Write(conf, "0.15.0", &stdout)
	assert.Nil(t, err)
	output := stdout.String()

	// Simple format assertions
	assert.True(t, strings.Contains(output, "OS:\n"))
	assert.True(t, strings.Contains(output, "BASH VERSION:\n"))
	assert.True(t, strings.Contains(output, "SHELL:\n"))
	assert.True(t, strings.Contains(output, "ASDF VERSION:\n"))
	assert.True(t, strings.Contains(output, "INTERNAL VARIABLES:\n"))
	assert.True(t, strings.Contains(output, "ASDF INSTALLED PLUGINS:\n"))
}
