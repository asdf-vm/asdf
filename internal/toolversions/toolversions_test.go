package toolversions

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestGetAllToolsAndVersions(t *testing.T) {
	t.Run("returns error when non-existant file", func(t *testing.T) {
		toolVersions, err := GetAllToolsAndVersions("non-existant-file")
		assert.Error(t, err)
		assert.Empty(t, toolVersions)
	})

	t.Run("returns list of tool versions when populated file", func(t *testing.T) {
		toolVersionsPath := filepath.Join(t.TempDir(), ".tool-versions")
		file, err := os.Create(toolVersionsPath)
		assert.Nil(t, err)
		defer file.Close()
		file.WriteString("ruby 2.0.0")

		toolVersions, err := GetAllToolsAndVersions(toolVersionsPath)
		assert.Nil(t, err)
		expected := []ToolVersions{{Name: "ruby", Versions: []string{"2.0.0"}}}
		assert.Equal(t, expected, toolVersions)
	})
}

func TestFindToolVersions(t *testing.T) {
	t.Run("returns error when non-existant file", func(t *testing.T) {
		versions, found, err := FindToolVersions("non-existant-file", "nonexistant-tool")
		assert.Error(t, err)
		assert.False(t, found)
		assert.Empty(t, versions)
	})

	t.Run("returns list of versions and found true when file contains tool versions", func(t *testing.T) {
		toolVersionsPath := filepath.Join(t.TempDir(), ".tool-versions")
		file, err := os.Create(toolVersionsPath)
		assert.Nil(t, err)
		defer file.Close()
		file.WriteString("ruby 2.0.0")

		versions, found, err := FindToolVersions(toolVersionsPath, "ruby")
		assert.Nil(t, err)
		assert.True(t, found)
		assert.Equal(t, []string{"2.0.0"}, versions)
	})
}

func TestUnique(t *testing.T) {
	t.Run("returns unique slice of tool versions when tool appears multiple times in slice", func(t *testing.T) {
		got := Unique([]ToolVersions{
			{Name: "foo", Versions: []string{"1"}},
			{Name: "foo", Versions: []string{"2"}},
		})

		want := []ToolVersions{
			{Name: "foo", Versions: []string{"1", "2"}},
		}

		assert.Equal(t, got, want)
	})

	t.Run("returns unique slice of tool versions when given slice with multiple tools", func(t *testing.T) {
		got := Unique([]ToolVersions{
			{Name: "foo", Versions: []string{"1"}},
			{Name: "bar", Versions: []string{"2"}},
			{Name: "foo", Versions: []string{"2"}},
			{Name: "bar", Versions: []string{"2"}},
		})

		want := []ToolVersions{
			{Name: "foo", Versions: []string{"1", "2"}},
			{Name: "bar", Versions: []string{"2"}},
		}

		assert.Equal(t, got, want)
	})
}

func TestfindToolVersionsInContent(t *testing.T) {
	t.Run("returns empty list with found false when empty content", func(t *testing.T) {
		versions, found := findToolVersionsInContent("", "ruby")
		assert.False(t, found)
		assert.Empty(t, versions)
	})

	t.Run("returns empty list with found false when tool not found", func(t *testing.T) {
		versions, found := findToolVersionsInContent("lua 5.4.5", "ruby")
		assert.False(t, found)
		assert.Empty(t, versions)
	})

	t.Run("returns list of versions with found true when tool found", func(t *testing.T) {
		versions, found := findToolVersionsInContent("lua 5.4.5 5.4.6\nruby 2.0.0", "lua")
		assert.True(t, found)
		assert.Equal(t, []string{"5.4.5", "5.4.6"}, versions)
	})
}

func TestgetAllToolsAndVersionsInContent(t *testing.T) {
	tests := []struct {
		desc  string
		input string
		want  []ToolVersions
	}{
		{
			desc:  "returns empty list with found true and no error when empty content",
			input: "",
			want:  []ToolVersions{},
		},
		{
			desc:  "returns list with one tool when single tool in content",
			input: "lua 5.4.5 5.4.6",
			want:  []ToolVersions{{Name: "lua", Versions: []string{"5.4.5", "5.4.6"}}},
		},
		{
			desc:  "returns list with multiple tools when multiple tools in content",
			input: "lua 5.4.5 5.4.6\nruby 2.0.0",
			want: []ToolVersions{
				{Name: "lua", Versions: []string{"5.4.5", "5.4.6"}},
				{Name: "ruby", Versions: []string{"2.0.0"}},
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.desc, func(t *testing.T) {
			toolsAndVersions := getAllToolsAndVersionsInContent(tt.input)
			assert.Equal(t, tt.want, toolsAndVersions)
		})
	}
}
