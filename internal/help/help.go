// Package help contains functions responsible for generating help output for
// asdf and asdf plugins.
package help

import (
	_ "embed"
	"fmt"
	"io"
	"os"

	"asdf/internal/config"
	"asdf/internal/plugins"
	"asdf/internal/toolversions"
)

//go:embed help.txt
var helpText string

const quote = "\"Late but latest\"\n-- Rajinikanth"

// Print help output to STDOUT
func Print(asdfVersion string) error {
	return Write(asdfVersion, os.Stdout)
}

// PrintTool write tool help output to STDOUT
func PrintTool(conf config.Config, toolName string) error {
	return WriteToolHelp(conf, toolName, os.Stdout, os.Stderr)
}

// PrintToolVersion write help for specific tool version to STDOUT
func PrintToolVersion(conf config.Config, toolName, toolVersion string) error {
	return WriteToolVersionHelp(conf, toolName, toolVersion, os.Stdout, os.Stderr)
}

// Write help output to an io.Writer
func Write(asdfVersion string, writer io.Writer) error {
	_, err := writer.Write([]byte(fmt.Sprintf("version: %s", asdfVersion)))
	if err != nil {
		return err
	}

	_, err = writer.Write([]byte(helpText))
	if err != nil {
		return err
	}

	_, err = writer.Write([]byte("\n"))
	if err != nil {
		return err
	}

	_, err = writer.Write([]byte(quote))
	if err != nil {
		return err
	}

	_, err = writer.Write([]byte("\n"))
	if err != nil {
		return err
	}

	return nil
}

// WriteToolHelp output to an io.Writer
func WriteToolHelp(conf config.Config, toolName string, writer io.Writer, errWriter io.Writer) error {
	return writePluginHelp(conf, toolName, "", writer, errWriter)
}

// WriteToolVersionHelp output to an io.Writer
func WriteToolVersionHelp(conf config.Config, toolName, toolVersion string, writer io.Writer, errWriter io.Writer) error {
	return writePluginHelp(conf, toolName, toolVersion, writer, errWriter)
}

func writePluginHelp(conf config.Config, toolName, toolVersion string, writer io.Writer, errWriter io.Writer) error {
	plugin := plugins.New(conf, toolName)
	env := map[string]string{
		"ASDF_INSTALL_PATH": plugin.Dir,
	}

	if toolVersion != "" {
		versionType, version := toolversions.Parse(toolVersion)
		env["ASDF_INSTALL_VERSION"] = version
		env["ASDF_INSTALL_TYPE"] = versionType
	}

	if err := plugin.Exists(); err != nil {
		errWriter.Write([]byte(fmt.Sprintf("No plugin named %s\n", plugin.Name)))
		return err
	}

	err := plugin.RunCallback("help.overview", []string{}, env, writer, errWriter)
	if _, ok := err.(plugins.NoCallbackError); ok {
		// No such callback, print err msg
		errWriter.Write([]byte(fmt.Sprintf("No documentation for plugin %s\n", plugin.Name)))
		return err
	}

	if err != nil {
		return err
	}

	err = plugin.RunCallback("help.deps", []string{}, env, writer, errWriter)
	if _, ok := err.(plugins.NoCallbackError); !ok {
		return err
	}

	err = plugin.RunCallback("help.config", []string{}, env, writer, errWriter)
	if _, ok := err.(plugins.NoCallbackError); !ok {
		return err
	}

	err = plugin.RunCallback("help.links", []string{}, env, writer, errWriter)
	if _, ok := err.(plugins.NoCallbackError); !ok {
		return err
	}

	return nil
}
