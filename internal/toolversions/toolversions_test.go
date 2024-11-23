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

func TestIntersect(t *testing.T) {
	t.Run("when provided two empty ToolVersions returns empty ToolVersions", func(t *testing.T) {
		got := Intersect([]string{}, []string{})
		want := []string(nil)

		assert.Equal(t, got, want)
	})

	t.Run("when provided ToolVersions with no matching versions return empty ToolVersions", func(t *testing.T) {
		got := Intersect([]string{"1", "2"}, []string{"3", "4"})

		assert.Equal(t, got, []string(nil))
	})

	t.Run("when provided ToolVersions with different versions return new ToolVersions only containing versions in both", func(t *testing.T) {
		got := Intersect([]string{"1", "2"}, []string{"2", "3"})
		want := []string{"2"}

		assert.Equal(t, got, want)
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

func TestParse(t *testing.T) {
	t.Run("when passed version string returns struct with type of 'version' and version as value", func(t *testing.T) {
		version := Parse("1.2.3")
		assert.Equal(t, version.Type, "version")
		assert.Equal(t, version.Value, "1.2.3")
	})

	t.Run("when passed ref and version returns struct with type of 'ref' and version as value", func(t *testing.T) {
		version := Parse("ref:abc123")
		assert.Equal(t, version.Type, "ref")
		assert.Equal(t, version.Value, "abc123")
	})

	t.Run("when passed 'ref:' returns struct with type of 'ref' and empty value", func(t *testing.T) {
		version := Parse("ref:")
		assert.Equal(t, version.Type, "ref")
		assert.Equal(t, version.Value, "")
	})

	t.Run("when passed 'system' returns struct with type of 'system'", func(t *testing.T) {
		version := Parse("system")
		assert.Equal(t, version.Type, "system")
		assert.Equal(t, version.Value, "")
	})
}

func TestParseFromCliArg(t *testing.T) {
	t.Run("when passed 'latest' returns struct with type of 'latest'", func(t *testing.T) {
		version := ParseFromCliArg("latest")
		assert.Equal(t, version.Type, "latest")
		assert.Equal(t, version.Value, "")
	})

	t.Run("when passed latest with filter returns struct with type of 'latest' and unmodified filter string as value", func(t *testing.T) {
		version := ParseFromCliArg("latest:1.2")
		assert.Equal(t, version.Type, "latest")
		assert.Equal(t, version.Value, "1.2")
	})

	t.Run("when passed version string returns struct with type of 'version' and version as value", func(t *testing.T) {
		version := ParseFromCliArg("1.2.3")
		assert.Equal(t, version.Type, "version")
		assert.Equal(t, version.Value, "1.2.3")
	})

	t.Run("when passed ref and version returns struct with type of 'ref' and version as value", func(t *testing.T) {
		version := ParseFromCliArg("ref:abc123")
		assert.Equal(t, version.Type, "ref")
		assert.Equal(t, version.Value, "abc123")
	})

	t.Run("when passed 'ref:' returns struct with type of 'ref' and empty value", func(t *testing.T) {
		version := ParseFromCliArg("ref:")
		assert.Equal(t, version.Type, "ref")
		assert.Equal(t, version.Value, "")
	})

	t.Run("when passed 'system' returns struct with type of 'system'", func(t *testing.T) {
		version := ParseFromCliArg("system")
		assert.Equal(t, version.Type, "system")
		assert.Equal(t, version.Value, "")
	})
}

func TestFormatForFS(t *testing.T) {
	t.Run("returns version when version type is not ref", func(t *testing.T) {
		assert.Equal(t, FormatForFS(Version{Type: "version", Value: "foobar"}), "foobar")
	})

	t.Run("returns version prefixed with 'ref-' when version type is ref", func(t *testing.T) {
		assert.Equal(t, FormatForFS(Version{Type: "ref", Value: "foobar"}), "ref-foobar")
	})
}
