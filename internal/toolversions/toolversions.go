// Package toolversions handles reading and writing tools and versions from
// asdf's .tool-versions files. It also handles parsing version strings from
// .tool-versions files and command line arguments.
package toolversions

import (
	"fmt"
	"os"
	"slices"
	"strings"
)

// Version struct represents a single version in asdf.
type Version struct {
	Type  string // Must be one of: version, ref, path, system, latest
	Value string // Any string
}

// ToolVersions represents a tool along with versions specified for it
type ToolVersions struct {
	Name     string
	Versions []string
}

// WriteToolVersionsToFile takes a path to a file and writes the new tool and
// version data to the file. It creates the file if it does not exist and
// updates it if it does.
func WriteToolVersionsToFile(filepath string, toolVersions []ToolVersions) error {
	content, err := os.ReadFile(filepath)
	if _, ok := err.(*os.PathError); err != nil && !ok {
		return err
	}

	updatedContent := updateContentWithToolVersions(string(content), toolVersions)
	return os.WriteFile(filepath, []byte(updatedContent), 0o666)
}

func updateContentWithToolVersions(content string, toolVersions []ToolVersions) string {
	var output strings.Builder

	if content != "" {
		for _, line := range readLines(content) {
			tokens, comment := parseLine(line)
			if len(tokens) > 1 {
				tv := ToolVersions{Name: tokens[0], Versions: tokens[1:]}

				indexMatching := slices.IndexFunc(toolVersions, func(toolVersion ToolVersions) bool {
					return toolVersion.Name == tv.Name
				})

				if indexMatching != -1 {
					// write updated version
					newTv := toolVersions[indexMatching]
					newTokens := toolVersionsToTokens(newTv)
					writeLine(&output, encodeLine(newTokens, comment))
					toolVersions = slices.Delete(toolVersions, indexMatching, indexMatching+1)
					continue
				}
			}

			// write back original line
			writeLine(&output, line)
		}
	}

	// If any ToolVersions structs remaining, write them to the end of the file
	if len(toolVersions) > 0 {
		for _, toolVersion := range toolVersions {
			newTokens := toolVersionsToTokens(toolVersion)
			writeLine(&output, encodeLine(newTokens, ""))
		}
	}

	return output.String()
}

// FindToolVersions looks up a tool version in a tool versions file and if found
// returns a slice of versions for it.
func FindToolVersions(filepath, toolName string) (versions []string, found bool, err error) {
	content, err := os.ReadFile(filepath)
	if err != nil {
		return versions, false, err
	}

	versions, found = findToolVersionsInContent(string(content), toolName)
	return versions, found, nil
}

// GetAllToolsAndVersions returns a list of all tools and associated versions
// contained in a .tool-versions file
func GetAllToolsAndVersions(filepath string) (toolVersions []ToolVersions, err error) {
	content, err := os.ReadFile(filepath)
	if err != nil {
		return toolVersions, err
	}

	toolVersions = getAllToolsAndVersionsInContent(string(content))
	return toolVersions, nil
}

// Intersect takes two slices of versions and returns a new slice containing
// only the versions found in both.
func Intersect(versions1 []string, versions2 []string) (versions []string) {
	for _, version1 := range versions1 {
		if slices.Contains(versions2, version1) {
			versions = append(versions, version1)
		}
	}
	return versions
}

// Unique takes a slice of ToolVersions and returns a slice of unique tools and
// versions.
func Unique(versions []ToolVersions) (uniques []ToolVersions) {
	for _, version := range versions {
		index := slices.IndexFunc(
			uniques,
			func(v ToolVersions) bool { return v.Name == version.Name },
		)
		if index < 0 {
			uniques = append(uniques, version)
			continue
		}

		unique := &uniques[index]
		for _, versionNumber := range version.Versions {
			if !slices.Contains(unique.Versions, versionNumber) {
				unique.Versions = append(unique.Versions, versionNumber)
			}
		}
	}

	return uniques
}

// ParseFromCliArg parses a string that is passed in as an argument to one of
// the asdf subcommands. Some subcommands allow the special version `latest` to
// be used, with an optional filter string.
func ParseFromCliArg(version string) Version {
	segments := strings.Split(version, ":")
	if len(segments) > 0 && segments[0] == "latest" {
		if len(segments) > 1 {
			// Must be latest with filter
			return Version{Type: "latest", Value: segments[1]}
		}
		return Version{Type: "latest", Value: ""}
	}

	return Parse(version)
}

// Parse parses a version string into versionType and version components
func Parse(version string) Version {
	segments := strings.Split(version, ":")
	if len(segments) >= 1 {
		remainder := strings.Join(segments[1:], ":")
		switch segments[0] {
		case "ref":
			return Version{Type: "ref", Value: remainder}
		case "path":
			// This is for people who have the local source already compiled
			// Like those who work on the language, etc
			// We'll allow specifying path:/foo/bar/project in .tool-versions
			// And then use the binaries there
			return Version{Type: "path", Value: remainder}
		default:
		}
	}

	if version == "system" {
		return Version{Type: "system"}
	}

	return Version{Type: "version", Value: version}
}

// ParseSlice takes a slice of strings and returns a slice of parsed versions.
func ParseSlice(versions []string) (parsedVersions []Version) {
	for _, version := range versions {
		parsedVersions = append(parsedVersions, Parse(version))
	}
	return parsedVersions
}

// Format takes a Version struct and formats it as a string
func Format(version Version) string {
	switch version.Type {
	case "system":
		return "system"
	case "path":
		return fmt.Sprintf("path:%s", version.Value)
	default:
		return version.Value
	}
}

// FormatForFS takes a versionType and version strings and generate a version
// string suitable for the file system
func FormatForFS(version Version) string {
	switch version.Type {
	case "ref":
		return fmt.Sprintf("ref-%s", version.Value)
	default:
		return version.Value
	}
}

func readLines(content string) (lines []string) {
	return strings.Split(content, "\n")
}

func findToolVersionsInContent(content, toolName string) (versions []string, found bool) {
	toolVersions := getAllToolsAndVersionsInContent(content)
	for _, tool := range toolVersions {
		if tool.Name == toolName {
			return tool.Versions, true
		}
	}

	return versions, found
}

func getAllToolsAndVersionsInContent(content string) (toolVersions []ToolVersions) {
	for _, line := range readLines(content) {
		tokens, _ := parseLine(line)
		if len(tokens) > 1 {
			newTool := ToolVersions{Name: tokens[0], Versions: tokens[1:]}
			toolVersions = append(toolVersions, newTool)
		}
	}

	return toolVersions
}

// parseLine receives a single line from a file and parses it into a list of
// tokens and a comment. A comment may occur anywhere on the line and is started
// by a `#` character.
func parseLine(line string) (tokens []string, comment string) {
	preComment, comment, _ := strings.Cut(line, "#")
	for _, token := range strings.Split(preComment, " ") {
		token = strings.TrimSpace(token)
		if len(token) > 0 {
			tokens = append(tokens, token)
		}
	}

	return tokens, comment
}

func toolVersionsToTokens(tv ToolVersions) []string {
	return append([]string{tv.Name}, tv.Versions...)
}

func encodeLine(tokens []string, comment string) string {
	tokensStr := strings.Join(tokens, " ")
	if comment == "" {
		if len(tokens) == 0 {
			return ""
		}
		return tokensStr
	}
	return fmt.Sprintf("%s #%s", tokensStr, comment)
}

func writeLine(output *strings.Builder, line string) {
	if strings.TrimSpace(line) != "" {
		output.WriteString(line + "\n")
	}
}
