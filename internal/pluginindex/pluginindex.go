// Package pluginindex is a package that handles fetching plugin repo URLs by
// name for user convenience.
package pluginindex

import (
	"fmt"
	"os"
	"path/filepath"
	"time"

	"asdf/internal/git"

	"gopkg.in/ini.v1"
)

const (
	pluginIndexDir      = "plugin-index"
	repoUpdatedFilename = "repo-updated"
)

// PluginIndex is a struct representing the user's preferences for plugin index
// and the plugin index on disk.
type PluginIndex struct {
	repo                  git.Repoer
	directory             string
	url                   string
	disableUpdate         bool
	updateDurationMinutes int
}

// Build returns a complete PluginIndex struct with default values set
func Build(dataDir string, URL string, disableUpdate bool, updateDurationMinutes int) PluginIndex {
	directory := filepath.Join(dataDir, pluginIndexDir)
	return New(directory, URL, disableUpdate, updateDurationMinutes, &git.Repo{Directory: directory})
}

// New initializes a new PluginIndex instance with the options passed in.
func New(directory, url string, disableUpdate bool, updateDurationMinutes int, repo git.Repoer) PluginIndex {
	return PluginIndex{
		repo:                  repo,
		directory:             directory,
		url:                   url,
		disableUpdate:         disableUpdate,
		updateDurationMinutes: updateDurationMinutes,
	}
}

// Refresh may update the plugin repo if it hasn't been updated in longer
// than updateDurationMinutes. If the plugin repo needs to be updated the
// repo will be invoked to perform the actual Git pull.
func (p PluginIndex) Refresh() (bool, error) {
	err := os.MkdirAll(p.directory, os.ModePerm)
	if err != nil {
		return false, err
	}

	files, err := os.ReadDir(p.directory)
	if err != nil {
		return false, err
	}

	if len(files) == 0 {
		// directory empty, clone down repo
		err := p.repo.Clone(p.url)
		if err != nil {
			return false, fmt.Errorf("unable to initialize index: %w", err)
		}

		return touchFS(p.directory)
	}

	// directory must not be empty, repo must be present, maybe update
	updated, err := lastUpdated(p.directory)
	if err != nil {
		return p.doUpdate()
	}

	// Convert minutes to nanoseconds
	updateDurationNs := int64(p.updateDurationMinutes) * (6e10)

	if updated > updateDurationNs && !p.disableUpdate {
		return p.doUpdate()
	}

	return false, nil
}

func (p PluginIndex) doUpdate() (bool, error) {
	// pass in empty string as we want the repo to figure out what the latest
	// commit is
	_, err := p.repo.Update("")
	if err != nil {
		return false, fmt.Errorf("unable to update plugin index: %w", err)
	}

	// Touch update file
	return touchFS(p.directory)
}

// GetPluginSourceURL looks up a plugin by name and returns the repository URL
// for easy install by the user.
func (p PluginIndex) GetPluginSourceURL(name string) (string, error) {
	_, err := p.Refresh()
	if err != nil {
		return "", err
	}

	url, err := readPlugin(p.directory, name)
	if err != nil {
		return "", err
	}

	return url, nil
}

func touchFS(directory string) (bool, error) {
	filename := filepath.Join(directory, repoUpdatedFilename)
	file, err := os.OpenFile(filename, os.O_RDONLY|os.O_CREATE, 0o666)
	if err != nil {
		return false, fmt.Errorf("unable to create file plugin index touch file: %w", err)
	}

	file.Close()
	return true, nil
}

func lastUpdated(dir string) (int64, error) {
	info, err := os.Stat(filepath.Join(dir, repoUpdatedFilename))
	if err != nil {
		return 0, fmt.Errorf("unable to read last updated file: %w", err)
	}

	// info.Atime_ns now contains the last access time
	updated := time.Now().UnixNano() - info.ModTime().UnixNano()
	return updated, nil
}

func readPlugin(dir, name string) (string, error) {
	filename := filepath.Join(dir, "plugins", name)

	pluginInfo, err := ini.Load(filename)
	if err != nil {
		return "", fmt.Errorf("plugin %s not found in repository", name)
	}

	return pluginInfo.Section("").Key("repository").String(), nil
}
