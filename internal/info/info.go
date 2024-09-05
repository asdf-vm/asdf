// Package info exists to print important info about this asdf installation to STDOUT for use in debugging and bug reports.
package info

import (
	"fmt"
	"io"
	"os"
	"text/tabwriter"

	"asdf/internal/config"
	"asdf/internal/execute"
	"asdf/internal/plugins"
)

// Print info output to STDOUT
func Print(conf config.Config, version string) error {
	return Write(conf, version, os.Stdout)
}

// Write info output to an io.Writer
func Write(conf config.Config, version string, writer io.Writer) error {
	fmt.Fprintln(writer, "OS:")
	uname := execute.NewExpression("uname -a", []string{})
	uname.Stdout = writer
	err := uname.Run()
	if err != nil {
		return err
	}

	fmt.Fprintln(writer, "\nSHELL:")
	shellVersion := execute.NewExpression("$SHELL --version", []string{})
	shellVersion.Stdout = writer
	err = shellVersion.Run()
	if err != nil {
		return err
	}

	fmt.Fprintln(writer, "\nBASH VERSION:")
	bashVersion := execute.NewExpression("echo $BASH_VERSION", []string{})
	bashVersion.Stdout = writer
	err = bashVersion.Run()
	if err != nil {
		return err
	}

	fmt.Fprintln(writer, "\nASDF VERSION:")
	fmt.Fprintf(writer, "%s\n", version)

	fmt.Fprintln(writer, "\nASDF INTERNAL VARIABLES:")
	fmt.Fprintf(writer, "ASDF_DEFAULT_TOOL_VERSIONS_FILENAME=%s\n", conf.DefaultToolVersionsFilename)
	fmt.Fprintf(writer, "ASDF_DATA_DIR=%s\n", conf.DataDir)
	fmt.Fprintf(writer, "ASDF_CONFIG_FILE=%s\n", conf.ConfigFile)

	fmt.Fprintln(writer, "\nASDF INSTALLED PLUGINS:")
	plugins, err := plugins.List(conf, true, true)
	if err != nil {
		fmt.Fprintf(writer, "error loading plugin list: %s", err)
		return err
	}

	pluginsTable(plugins, writer)

	return nil
}

func pluginsTable(plugins []plugins.Plugin, output io.Writer) error {
	writer := tabwriter.NewWriter(output, 10, 4, 1, ' ', 0)

	for _, plugin := range plugins {
		fmt.Fprintf(writer, "%s\t%s\t%s\n", plugin.Name, plugin.URL, plugin.Ref)
	}

	return writer.Flush()
}
