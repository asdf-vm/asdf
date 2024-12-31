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

func TestWriteToolVersionsToFile(t *testing.T) {
	toolVersions := ToolVersions{Name: "lua", Versions: []string{"1.2.3"}}

	t.Run("writes new file when it does not exist", func(t *testing.T) {
		path := filepath.Join(t.TempDir(), ".tool-versions")
		assert.Nil(t, WriteToolVersionsToFile(path, []ToolVersions{toolVersions}))

		fileContents, err := os.ReadFile(path)
		assert.Nil(t, err)
		assert.Equal(t, string(fileContents), "lua 1.2.3\n")
	})

	t.Run("writes new line to end of file when version not already set", func(t *testing.T) {
		path := filepath.Join(t.TempDir(), ".tool-versions")
		assert.Nil(t, os.WriteFile(path, []byte("test 1.2.3"), 0o666))
		assert.Nil(t, WriteToolVersionsToFile(path, []ToolVersions{toolVersions}))

		fileContents, err := os.ReadFile(path)
		assert.Nil(t, err)
		assert.Equal(t, string(fileContents), "test 1.2.3\nlua 1.2.3\n")
	})

	t.Run("updates existing line when tool already has one or more versions set", func(t *testing.T) {
		path := filepath.Join(t.TempDir(), ".tool-versions")
		assert.Nil(t, os.WriteFile(path, []byte("lua 1.1.1"), 0o666))
		assert.Nil(t, WriteToolVersionsToFile(path, []ToolVersions{toolVersions}))

		fileContents, err := os.ReadFile(path)
		assert.Nil(t, err)
		assert.Equal(t, string(fileContents), "lua 1.2.3\n")
	})
}

func TestUpdateContentWithToolVersions(t *testing.T) {
	tests := []struct {
		desc         string
		input        string
		toolVersions []ToolVersions
		output       string
	}{
		{
			desc:         "returns content unchanged when identical tool and version already set",
			input:        "foobar 1.2.3",
			toolVersions: []ToolVersions{{Name: "foobar", Versions: []string{"1.2.3"}}},
			output:       "foobar 1.2.3\n",
		},
		{
			desc:         "writes new line to end of file when version not already set",
			input:        "foobar 1.2.3",
			toolVersions: []ToolVersions{{Name: "test", Versions: []string{"4.5.6"}}},
			output:       "foobar 1.2.3\ntest 4.5.6\n",
		},
		{
			desc:         "preserves comments on all other lines",
			input:        "foobar 1.2.3\n# this is a test",
			toolVersions: []ToolVersions{{Name: "foobar", Versions: []string{"4.5.6"}}},
			output:       "foobar 4.5.6\n# this is a test\n",
		},
		{
			desc:         "preserves comment on end of the line specifying previous version",
			input:        "foobar 1.2.3 # this is a test",
			toolVersions: []ToolVersions{{Name: "foobar", Versions: []string{"4.5.6"}}},
			output:       "foobar 4.5.6 # this is a test\n",
		},
		{
			desc:         "writes multiple versions for same tool",
			input:        "foobar 1.2.3",
			toolVersions: []ToolVersions{{Name: "foobar", Versions: []string{"4.5.6", "1.2.3"}}},
			output:       "foobar 4.5.6 1.2.3\n",
		},
		{
			desc:  "writes multiple tools",
			input: "foobar 1.2.3",
			toolVersions: []ToolVersions{
				{Name: "ruby", Versions: []string{"4.5.6", "1.2.3"}},
				{Name: "lua", Versions: []string{"5.2.3"}},
			},
			output: "foobar 1.2.3\nruby 4.5.6 1.2.3\nlua 5.2.3\n",
		},
		{
			desc:         "writes new version when empty string",
			input:        "",
			toolVersions: []ToolVersions{{Name: "foobar", Versions: []string{"1.2.3"}}},
			output:       "foobar 1.2.3\n",
		},
		{
			desc:         "writes new version when empty string",
			input:        "# this is a test",
			toolVersions: []ToolVersions{{Name: "foobar", Versions: []string{"1.2.3"}}},
			output:       "# this is a test\nfoobar 1.2.3\n",
		},
	}

	for _, tt := range tests {
		t.Run(tt.desc, func(t *testing.T) {
			output := updateContentWithToolVersions(tt.input, tt.toolVersions)
			assert.Equal(t, tt.output, output)
		})
	}
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

func TestFindToolVersionsInContent(t *testing.T) {
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

func TestGetAllToolsAndVersionsInContent(t *testing.T) {
	tests := []struct {
		desc  string
		input string
		want  []ToolVersions
	}{
		{
			desc:  "returns empty list with found true and no error when empty content",
			input: "",
			want:  []ToolVersions(nil),
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
			if len(tt.want) == 0 {
				assert.Empty(t, toolsAndVersions)
				return
			}
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

func TestParseSlice(t *testing.T) {
	t.Run("returns slice of parsed tool versions", func(t *testing.T) {
		versions := ParseSlice([]string{"1.2.3"})
		assert.Equal(t, []Version{{Type: "version", Value: "1.2.3"}}, versions)
	})

	t.Run("returns empty slice when empty slice provided", func(t *testing.T) {
		versions := ParseSlice([]string{})
		assert.Empty(t, versions)
	})

	t.Run("parses special versions", func(t *testing.T) {
		versions := ParseSlice([]string{"ref:foo", "system", "path:/foo/bar"})
		assert.Equal(t, []Version{{Type: "ref", Value: "foo"}, {Type: "system"}, {Type: "path", Value: "/foo/bar"}}, versions)
	})
}

func TestFormat(t *testing.T) {
	tests := []struct {
		desc   string
		input  Version
		output string
	}{
		{
			desc:   "with regular version",
			input:  Version{Type: "version", Value: "foobar"},
			output: "foobar",
		},
		{
			desc:   "with ref version",
			input:  Version{Type: "ref", Value: "foobar"},
			output: "foobar",
		},
		{
			desc:   "with system version",
			input:  Version{Type: "system", Value: "system"},
			output: "system",
		},
		{
			desc:   "with system version",
			input:  Version{Type: "path", Value: "/foo/bar"},
			output: "path:/foo/bar",
		},
	}

	for _, tt := range tests {
		t.Run(tt.desc, func(t *testing.T) {
			got := Format(tt.input)
			assert.Equal(t, got, tt.output)
		})
	}
}

func TestFormatForFS(t *testing.T) {
	t.Run("returns version when version type is not ref", func(t *testing.T) {
		assert.Equal(t, FormatForFS(Version{Type: "version", Value: "foobar"}), "foobar")
	})

	t.Run("returns version prefixed with 'ref-' when version type is ref", func(t *testing.T) {
		assert.Equal(t, FormatForFS(Version{Type: "ref", Value: "foobar"}), "ref-foobar")
	})
}

func BenchmarkUnique(b *testing.B) {
	versions := []ToolVersions{
		{Name: "foo", Versions: []string{"1"}},
		{Name: "bar", Versions: []string{"2"}},
		{Name: "foo", Versions: []string{"2"}},
		{Name: "bar", Versions: []string{"2"}},
	}

	for i := 0; i < b.N; i++ {
		Unique(versions)
	}
}
