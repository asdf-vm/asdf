package info

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/asdf-vm/asdf/internal/config"
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

func TestWrite_WithEnvironmentWarnings(t *testing.T) {
	testDataDir := t.TempDir()
	err := os.MkdirAll(filepath.Join(testDataDir, "plugins"), 0o777)
	assert.Nil(t, err)

	// Set an invalid environment variable to trigger a warning
	t.Setenv("ASDF_TOOL_VERSIONS_FILENAME", "/home/user/.config/asdf/tool-versions")

	conf := config.Config{DataDir: testDataDir}
	var stdout strings.Builder

	err = Write(conf, "0.15.0", &stdout)
	assert.Nil(t, err)
	output := stdout.String()

	// Check that warnings are displayed
	assert.True(t, strings.Contains(output, "WARNINGS:"))
	assert.True(t, strings.Contains(output, "ASDF_TOOL_VERSIONS_FILENAME should be a filename only"))
}

func TestValidateEnvironment(t *testing.T) {
	tests := []struct {
		name          string
		envValue      string
		expectWarning bool
	}{
		{
			name:          "warns for absolute path",
			envValue:      "/home/user/.config/asdf/tool-versions",
			expectWarning: true,
		},
		{
			name:          "warns for relative path",
			envValue:      ".config/tool-versions",
			expectWarning: true,
		},
		{
			name:          "warns for tilde path",
			envValue:      "~/.tool-versions",
			expectWarning: true,
		},
		{
			name:          "warns for Windows path",
			envValue:      "config\\tool-versions",
			expectWarning: true,
		},
		{
			name:          "no warnings for valid filename",
			envValue:      ".tool-versions",
			expectWarning: false,
		},
		{
			name:          "no warnings for custom filename",
			envValue:      "versions",
			expectWarning: false,
		},
		{
			name:          "no warnings when empty",
			envValue:      "",
			expectWarning: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if tt.envValue != "" {
				t.Setenv("ASDF_TOOL_VERSIONS_FILENAME", tt.envValue)
			}

			warnings := validateEnvironment()

			if tt.expectWarning {
				assert.Len(t, warnings, 1)
				assert.Contains(t, warnings[0], "should be a filename only")
			} else {
				assert.Empty(t, warnings)
			}
		})
	}
}
