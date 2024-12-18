// Package completions handles shell completion files.
//
// To add completion support for a shell, simply add a file named
// "asdf.<shell>" to this directory, replacing "<shell>" with the name
// of the shell.
package completions

import (
	"embed"
	"errors"
	"io/fs"
	"slices"
	"strings"
)

//go:embed asdf.*
var completions embed.FS

func Get(name string) (fs.File, bool) {
	file, err := completions.Open("asdf." + name)
	if err != nil {
		if errors.Is(err, fs.ErrNotExist) {
			return nil, false
		}
		panic(err) // This should never happen.
	}
	return file, true
}

func Names() []string {
	files, _ := fs.Glob(completions, "asdf.*")
	for i, file := range files {
		files[i] = strings.TrimPrefix(file, "asdf.")
	}
	slices.Sort(files)
	return files
}
