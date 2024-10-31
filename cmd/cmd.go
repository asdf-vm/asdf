// Package cmd contains the asdf CLI command code
package cmd

import (
	"errors"
	"fmt"
	"io"
	"log"
	"os"
	"path/filepath"
	"slices"
	"strings"
	"text/tabwriter"

	"asdf/internal/config"
	"asdf/internal/exec"
	"asdf/internal/help"
	"asdf/internal/info"
	"asdf/internal/installs"
	"asdf/internal/plugins"
	"asdf/internal/resolve"
	"asdf/internal/shims"
	"asdf/internal/toolversions"
	"asdf/internal/versions"

	"github.com/urfave/cli/v2"
)

const usageText = `The Multiple Runtime Version Manager.

Manage all your runtime versions with one tool!

Complete documentation is available at https://asdf-vm.com/`

// Execute defines the full CLI API and then runs it
func Execute(version string) {
	logger := log.New(os.Stderr, "", 0)
	log.SetFlags(0)

	app := &cli.App{
		Name:    "asdf",
		Version: "0.1.0",
		// Not really sure what I should put here, but all the new Golang code will
		// likely be written by me.
		Copyright: "(c) 2024 Trevor Brown",
		Authors: []*cli.Author{
			{
				Name: "Trevor Brown",
			},
		},
		Usage:     "The multiple runtime version manager",
		UsageText: usageText,
		Commands: []*cli.Command{
			{
				Name: "current",
				Action: func(cCtx *cli.Context) error {
					tool := cCtx.Args().Get(0)

					return currentCommand(logger, tool)
				},
			},
			{
				Name: "exec",
				Action: func(cCtx *cli.Context) error {
					command := cCtx.Args().Get(0)
					args := cCtx.Args().Slice()

					return execCommand(logger, command, args)
				},
			},
			{
				Name: "help",
				Action: func(cCtx *cli.Context) error {
					toolName := cCtx.Args().Get(0)
					toolVersion := cCtx.Args().Get(1)
					return helpCommand(logger, version, toolName, toolVersion)
				},
			},
			{
				Name: "info",
				Action: func(_ *cli.Context) error {
					conf, err := config.LoadConfig()
					if err != nil {
						logger.Printf("error loading config: %s", err)
						return err
					}

					return infoCommand(conf, version)
				},
			},
			{
				Name: "install",
				Action: func(cCtx *cli.Context) error {
					args := cCtx.Args()
					return installCommand(logger, args.Get(0), args.Get(1))
				},
			},
			{
				Name: "latest",
				Flags: []cli.Flag{
					&cli.BoolFlag{
						Name:  "all",
						Usage: "Show latest version of all tools",
					},
				},
				Action: func(cCtx *cli.Context) error {
					tool := cCtx.Args().Get(0)
					pattern := cCtx.Args().Get(1)
					all := cCtx.Bool("all")

					return latestCommand(logger, all, tool, pattern)
				},
			},
			{
				Name: "list",
				Action: func(cCtx *cli.Context) error {
					args := cCtx.Args()
					return listCommand(logger, args.Get(0), args.Get(1), args.Get(2))
				},
			},
			{
				Name: "plugin",
				Action: func(_ *cli.Context) error {
					logger.Println("Unknown command: `asdf plugin`")
					os.Exit(1)
					return nil
				},
				Subcommands: []*cli.Command{
					{
						Name: "add",
						Action: func(cCtx *cli.Context) error {
							args := cCtx.Args()
							conf, err := config.LoadConfig()
							if err != nil {
								logger.Printf("error loading config: %s", err)
								return err
							}

							return pluginAddCommand(cCtx, conf, logger, args.Get(0), args.Get(1))
						},
					},
					{
						Name: "list",
						Flags: []cli.Flag{
							&cli.BoolFlag{
								Name:  "urls",
								Usage: "Show URLs",
							},
							&cli.BoolFlag{
								Name:  "refs",
								Usage: "Show Refs",
							},
						},
						Action: func(cCtx *cli.Context) error {
							return pluginListCommand(cCtx, logger)
						},
					},
					{
						Name: "remove",
						Action: func(cCtx *cli.Context) error {
							args := cCtx.Args()
							return pluginRemoveCommand(cCtx, logger, args.Get(0))
						},
					},
					{
						Name: "update",
						Flags: []cli.Flag{
							&cli.BoolFlag{
								Name:  "all",
								Usage: "Update all installed plugins",
							},
						},
						Action: func(cCtx *cli.Context) error {
							args := cCtx.Args()
							return pluginUpdateCommand(cCtx, logger, args.Get(0), args.Get(1))
						},
					},
				},
			},
			{
				Name: "reshim",
				Action: func(cCtx *cli.Context) error {
					args := cCtx.Args()
					return reshimCommand(logger, args.Get(0), args.Get(1))
				},
			},
			{
				Name: "shimversions",
				Action: func(cCtx *cli.Context) error {
					args := cCtx.Args()
					return shimVersionsCommand(logger, args.Get(0))
				},
			},
			{
				Name: "uninstall",
				Action: func(cCtx *cli.Context) error {
					tool := cCtx.Args().Get(0)
					version := cCtx.Args().Get(1)

					return uninstallCommand(logger, tool, version)
				},
			},
			{
				Name: "where",
				Action: func(cCtx *cli.Context) error {
					tool := cCtx.Args().Get(0)
					version := cCtx.Args().Get(1)

					return whereCommand(logger, tool, version)
				},
			},
			{
				Name: "which",
				Action: func(cCtx *cli.Context) error {
					tool := cCtx.Args().Get(0)

					return whichCommand(logger, tool)
				},
			},
		},
		Action: func(_ *cli.Context) error {
			// TODO: flesh this out
			log.Print("Late but latest -- Rajinikanth")
			return nil
		},
	}

	err := app.Run(os.Args)
	if err != nil {
		os.Exit(1)
	}
}

// This function is a whole mess and needs to be refactored
func currentCommand(logger *log.Logger, tool string) error {
	conf, err := config.LoadConfig()
	if err != nil {
		logger.Printf("error loading config: %s", err)
		return err
	}

	currentDir, err := os.Getwd()
	if err != nil {
		logger.Printf("unable to get current directory: %s", err)
		return err
	}

	// settings here to match legacy implementation
	w := tabwriter.NewWriter(os.Stdout, 16, 0, 1, ' ', 0)

	if tool == "" {
		// show all
		allPlugins, err := plugins.List(conf, false, false)
		if err != nil {
			return err
		}

		if len(allPlugins) < 1 {
			fmt.Println("No plugins installed")
			return nil
		}

		for _, plugin := range allPlugins {
			toolversion, versionFound, versionInstalled := getVersionInfo(conf, plugin, currentDir)
			formatCurrentVersionLine(w, plugin, toolversion, versionFound, versionInstalled, err)
		}
		w.Flush()
		return nil
	}

	// show single tool
	plugin := plugins.New(conf, tool)

	err = plugin.Exists()
	_, ok := err.(plugins.PluginMissing)
	pluginExists := !ok

	if pluginExists {
		toolversion, versionFound, versionInstalled := getVersionInfo(conf, plugin, currentDir)
		formatCurrentVersionLine(w, plugin, toolversion, versionFound, versionInstalled, err)
		w.Flush()
		if !versionFound {
			os.Exit(126)
		}

		if !versionInstalled {
			os.Exit(1)
		}
	} else {
		fmt.Printf("No such plugin: %s\n", tool)
		return err
	}

	return nil
}

func getVersionInfo(conf config.Config, plugin plugins.Plugin, currentDir string) (resolve.ToolVersions, bool, bool) {
	toolversion, found, _ := resolve.Version(conf, plugin, currentDir)
	installed := false
	if found {
		firstVersion := toolversion.Versions[0]
		versionType, version := toolversions.Parse(firstVersion)
		installed = installs.IsInstalled(conf, plugin, versionType, version)
	}
	return toolversion, found, installed
}

func formatCurrentVersionLine(w *tabwriter.Writer, plugin plugins.Plugin, toolversion resolve.ToolVersions, found bool, installed bool, err error) error {
	if err != nil {
		return err
	}

	fmt.Fprintf(w, "%s\t%s\t%s\n", plugin.Name, formatVersions(toolversion.Versions), formatSource(toolversion, plugin, found, installed))
	return nil
}

func formatSource(toolversion resolve.ToolVersions, plugin plugins.Plugin, found bool, installed bool) string {
	if found {
		if !installed {
			return fmt.Sprintf("Not installed. Run \"asdf install %s %s\"", plugin.Name, toolversion.Versions[0])
		}
		return filepath.Join(toolversion.Directory, toolversion.Source)
	}
	return fmt.Sprintf("No version is set. Run \"asdf <global|shell|local> %s <version>\"", plugin.Name)
}

func formatVersions(versions []string) string {
	switch len(versions) {
	case 0:
		return "______"
	case 1:
		return versions[0]
	default:
		return strings.Join(versions, " ")
	}
}

func execCommand(logger *log.Logger, command string, args []string) error {
	if command == "" {
		logger.Printf("usage: asdf exec <command>")
		return fmt.Errorf("usage: asdf exec <command>")
	}

	conf, err := config.LoadConfig()
	if err != nil {
		logger.Printf("error loading config: %s", err)
		return err
	}

	currentDir, err := os.Getwd()
	if err != nil {
		logger.Printf("unable to get current directory: %s", err)
		return err
	}

	executable, found, err := shims.FindExecutable(conf, command, currentDir)
	if err != nil {
		logger.Printf("executable not found due to reason: %s", err.Error())
		return err
	}

	if !found {
		logger.Print("executable not found")
		return fmt.Errorf("executable not found")
	}
	if len(args) > 1 {
		args = args[1:]
	} else {
		args = []string{}
	}

	return exec.Exec(executable, args, os.Environ())
}

func pluginAddCommand(_ *cli.Context, conf config.Config, logger *log.Logger, pluginName, pluginRepo string) error {
	if pluginName == "" {
		// Invalid arguments
		// Maybe one day switch this to show the generated help
		// cli.ShowSubcommandHelp(cCtx)
		return cli.Exit("usage: asdf plugin add <name> [<git-url>]", 1)
	}

	err := plugins.Add(conf, pluginName, pluginRepo)
	if err != nil {
		logger.Printf("%s", err)

		var existsErr plugins.PluginAlreadyExists
		if errors.As(err, &existsErr) {
			os.Exit(0)
			return nil
		}

		os.Exit(1)
		return nil
	}

	os.Exit(0)
	return nil
}

func pluginRemoveCommand(_ *cli.Context, logger *log.Logger, pluginName string) error {
	if pluginName == "" {
		logger.Print("No plugin given")
		os.Exit(1)
		return nil
	}

	conf, err := config.LoadConfig()
	if err != nil {
		logger.Printf("error loading config: %s", err)
		return err
	}

	err = plugins.Remove(conf, pluginName, os.Stdout, os.Stderr)
	if err != nil {
		// Needed to match output of old version
		logger.Printf("%s", err)
	}

	// This feels a little hacky but it works, to re-generate shims we delete them
	// all and generate them again.
	err2 := shims.RemoveAll(conf)
	if err2 != nil {
		logger.Printf("%s", err2)
		os.Exit(1)
		return err2
	}

	shims.GenerateAll(conf, os.Stdout, os.Stderr)
	return err
}

func pluginListCommand(cCtx *cli.Context, logger *log.Logger) error {
	urls := cCtx.Bool("urls")
	refs := cCtx.Bool("refs")

	conf, err := config.LoadConfig()
	if err != nil {
		logger.Printf("error loading config: %s", err)
		return err
	}

	plugins, err := plugins.List(conf, urls, refs)
	if err != nil {
		logger.Printf("error loading plugin list: %s", err)
		return err
	}

	// TODO: Add some sort of presenter logic in another file so we
	// don't clutter up this cmd code with conditional presentation
	// logic
	for _, plugin := range plugins {
		if urls && refs {
			logger.Printf("%s\t\t%s\t%s\n", plugin.Name, plugin.URL, plugin.Ref)
		} else if refs {
			logger.Printf("%s\t\t%s\n", plugin.Name, plugin.Ref)
		} else if urls {
			logger.Printf("%s\t\t%s\n", plugin.Name, plugin.URL)
		} else {
			logger.Printf("%s\n", plugin.Name)
		}
	}

	return nil
}

func infoCommand(conf config.Config, version string) error {
	return info.Print(conf, version)
}

func helpCommand(logger *log.Logger, asdfVersion, tool, version string) error {
	conf, err := config.LoadConfig()
	if err != nil {
		logger.Printf("error loading config: %s", err)
		return err
	}

	if tool != "" {
		if version != "" {
			err := help.PrintToolVersion(conf, tool, version)
			if err != nil {
				os.Exit(1)
			}
			return err
		}

		err := help.PrintTool(conf, tool)
		if err != nil {
			os.Exit(1)
		}
		return err
	}

	err = help.Print(asdfVersion)
	if err != nil {
		os.Exit(1)
	}
	return err
}

func pluginUpdateCommand(cCtx *cli.Context, logger *log.Logger, pluginName, ref string) error {
	updateAll := cCtx.Bool("all")
	if !updateAll && pluginName == "" {
		return cli.Exit("usage: asdf plugin-update {<name> [git-ref] | --all}", 1)
	}

	conf, err := config.LoadConfig()
	if err != nil {
		logger.Printf("error loading config: %s", err)
		return err
	}

	if updateAll {
		installedPlugins, err := plugins.List(conf, false, false)
		if err != nil {
			logger.Printf("failed to get plugin list: %s", err)
			return err
		}

		for _, plugin := range installedPlugins {
			updatedToRef, err := plugins.Update(conf, plugin.Name, "")
			formatUpdateResult(logger, plugin.Name, updatedToRef, err)
		}

		return nil
	}

	updatedToRef, err := plugins.Update(conf, pluginName, ref)
	formatUpdateResult(logger, pluginName, updatedToRef, err)
	return err
}

func formatUpdateResult(logger *log.Logger, pluginName, updatedToRef string, err error) {
	if err != nil {
		logger.Printf("failed to update %s due to error: %s\n", pluginName, err)

		return
	}

	logger.Printf("updated %s to ref %s\n", pluginName, updatedToRef)
}

func installCommand(logger *log.Logger, toolName, version string) error {
	conf, err := config.LoadConfig()
	if err != nil {
		logger.Printf("error loading config: %s", err)
		return err
	}

	dir, err := os.Getwd()
	if err != nil {
		return fmt.Errorf("unable to fetch current directory: %w", err)
	}

	if toolName == "" {
		// Install all versions
		errs := versions.InstallAll(conf, dir, os.Stdout, os.Stderr)
		if len(errs) > 0 {
			for _, err := range errs {
				os.Stderr.Write([]byte(err.Error()))
				os.Stderr.Write([]byte("\n"))
			}

			filtered := filterInstallErrors(errs)
			if len(filtered) > 0 {
				return filtered[0]
			}
			return nil
		}
	} else {
		// Install specific version
		plugin := plugins.New(conf, toolName)

		if version == "" {
			err = versions.Install(conf, plugin, dir, os.Stdout, os.Stderr)
			if err != nil {
				return err
			}
		} else {
			parsedVersion, query := toolversions.ParseFromCliArg(version)

			if parsedVersion == "latest" {
				err = versions.InstallVersion(conf, plugin, version, query, os.Stdout, os.Stderr)
			} else {
				err = versions.InstallOneVersion(conf, plugin, version, os.Stdout, os.Stderr)
			}

			if err != nil {
				logger.Printf("error installing version: %s", err)
			}
		}
	}

	return err
}

func filterInstallErrors(errs []error) []error {
	var filtered []error
	for _, err := range errs {
		if _, ok := err.(versions.NoVersionSetError); !ok {
			filtered = append(filtered, err)
		}
	}
	return filtered
}

func latestCommand(logger *log.Logger, all bool, toolName, pattern string) (err error) {
	conf, err := config.LoadConfig()
	if err != nil {
		logger.Printf("error loading config: %s", err)
		return err
	}

	if !all {
		err = latestForPlugin(conf, toolName, pattern, false)
		if err != nil {
			os.Exit(1)
		}

		return err
	}

	plugins, err := plugins.List(conf, false, false)
	if err != nil {
		logger.Printf("error loading plugin list: %s", err)
		return err
	}

	var maybeErr error
	// loop over all plugins and show latest for each one.
	for _, plugin := range plugins {
		maybeErr = latestForPlugin(conf, plugin.Name, "", true)
		if maybeErr != nil {
			err = maybeErr
		}
	}

	if err != nil {
		os.Exit(1)
		return maybeErr
	}
	return nil
}

func listCommand(logger *log.Logger, first, second, third string) (err error) {
	conf, err := config.LoadConfig()
	if err != nil {
		logger.Printf("error loading config: %s", err)
		return err
	}

	// Both listAllCommand and listLocalCommand need to be refactored and extracted
	// out into another package.
	if first == "all" {
		return listAllCommand(logger, conf, second, third)
	}

	return listLocalCommand(logger, conf, first, second)
}

func listAllCommand(logger *log.Logger, conf config.Config, toolName, filter string) error {
	if toolName == "" {
		logger.Print("No plugin given")
		os.Exit(1)
		return nil
	}

	plugin := plugins.New(conf, toolName)
	var stdout strings.Builder
	var stderr strings.Builder

	err := plugin.RunCallback("list-all", []string{}, map[string]string{}, &stdout, &stderr)
	if err != nil {
		fmt.Printf("Plugin %s's list-all callback script failed with output:\n", plugin.Name)
		// Print to stderr
		os.Stderr.WriteString(stderr.String())
		os.Stderr.WriteString(stdout.String())

		os.Exit(1)
		return err
	}

	versions := strings.Split(stdout.String(), " ")

	if filter != "" {
		versions = filterByExactMatch(versions, filter)
	}

	if len(versions) == 0 {
		logger.Printf("No compatible versions available (%s %s)", plugin.Name, filter)
		os.Exit(1)
		return nil
	}

	for _, version := range versions {
		fmt.Printf("%s\n", version)
	}

	return nil
}

func filterByExactMatch(allVersions []string, pattern string) (versions []string) {
	for _, version := range allVersions {
		if strings.HasPrefix(version, pattern) {
			versions = append(versions, version)
		}
	}

	return versions
}

func listLocalCommand(logger *log.Logger, conf config.Config, pluginName, filter string) error {
	currentDir, err := os.Getwd()
	if err != nil {
		logger.Printf("unable to get current directory: %s", err)
		return err
	}

	if pluginName != "" {
		plugin := plugins.New(conf, pluginName)
		versions, _ := installs.Installed(conf, plugin)

		if filter != "" {
			versions = filterByExactMatch(versions, filter)
		}

		if len(versions) == 0 {
			logger.Printf("No compatible versions installed (%s %s)", plugin.Name, filter)
			os.Exit(1)
			return nil
		}

		currentVersions, _, err := resolve.Version(conf, plugin, currentDir)
		if err != nil {
			os.Exit(1)
			return err
		}

		for _, version := range versions {
			if slices.Contains(currentVersions.Versions, version) {
				fmt.Printf(" *%s\n", version)
			} else {
				fmt.Printf("  %s\n", version)
			}
		}
		return nil
	}

	allPlugins, err := plugins.List(conf, false, false)
	if err != nil {
		logger.Printf("unable to list plugins due to error: %s", err)
		return err
	}

	for _, plugin := range allPlugins {
		fmt.Printf("%s\n", plugin.Name)
		versions, _ := installs.Installed(conf, plugin)

		if len(versions) > 0 {
			currentVersions, _, err := resolve.Version(conf, plugin, currentDir)
			if err != nil {
				os.Exit(1)
				return err
			}
			for _, version := range versions {
				if slices.Contains(currentVersions.Versions, version) {
					fmt.Printf(" *%s\n", version)
				} else {
					fmt.Printf("  %s\n", version)
				}
			}
		} else {
			fmt.Print("  No versions installed\n")
		}
	}

	return nil
}

func reshimCommand(logger *log.Logger, tool, version string) (err error) {
	conf, err := config.LoadConfig()
	if err != nil {
		logger.Printf("error loading config: %s", err)
		return err
	}

	// if either tool or version are missing just regenerate all shims. This is
	// fast enough now.
	if tool == "" || version == "" {
		err = shims.RemoveAll(conf)
		if err != nil {
			return err
		}

		return shims.GenerateAll(conf, os.Stdout, os.Stderr)
	}

	// If provided a specific version it could be something special like a path
	// version so we need to generate it manually
	return reshimToolVersion(conf, tool, version, os.Stdout, os.Stderr)
}

func shimVersionsCommand(logger *log.Logger, shimName string) error {
	conf, err := config.LoadConfig()
	if err != nil {
		logger.Printf("error loading config: %s", err)
		return err
	}

	shimPath := shims.Path(conf, shimName)
	toolVersions, err := shims.GetToolsAndVersionsFromShimFile(shimPath)
	for _, toolVersion := range toolVersions {
		for _, version := range toolVersion.Versions {
			fmt.Printf("%s %s", toolVersion.Name, version)
		}
	}
	return err
}

// This function is a whole mess and needs to be refactored
func whichCommand(logger *log.Logger, command string) error {
	conf, err := config.LoadConfig()
	if err != nil {
		logger.Printf("error loading config: %s", err)
		return err
	}

	currentDir, err := os.Getwd()
	if err != nil {
		logger.Printf("unable to get current directory: %s", err)
		return err
	}

	if command == "" {
		fmt.Println("usage: asdf which <command>")
		return errors.New("must provide command")
	}

	path, _, err := shims.FindExecutable(conf, command, currentDir)
	if _, ok := err.(shims.UnknownCommandError); ok {
		logger.Printf("unknown command: %s. Perhaps you have to reshim?", command)
		return errors.New("command not found")
	}

	if _, ok := err.(shims.NoExecutableForPluginError); ok {
		logger.Printf("%s", err.Error())
		return errors.New("no executable for tool version")
	}

	if err != nil {
		fmt.Printf("unexpected error: %s\n", err.Error())
		return err
	}

	fmt.Printf("%s\n", path)
	return nil
}

func uninstallCommand(logger *log.Logger, tool, version string) error {
	if tool == "" || version == "" {
		logger.Print("No plugin given")
		os.Exit(1)
		return nil
	}

	conf, err := config.LoadConfig()
	if err != nil {
		logger.Printf("error loading config: %s", err)
		os.Exit(1)
		return err
	}

	plugin := plugins.New(conf, tool)
	err = versions.Uninstall(conf, plugin, version, os.Stdout, os.Stderr)
	if err != nil {
		logger.Printf("%s", err)
		os.Exit(1)
		return err
	}

	// This feels a little hacky but it works, to re-generate shims we delete them
	// all and generate them again.
	err = shims.RemoveAll(conf)
	if err != nil {
		logger.Printf("%s", err)
		os.Exit(1)
		return err
	}

	return shims.GenerateAll(conf, os.Stdout, os.Stderr)
}

func whereCommand(logger *log.Logger, tool, version string) error {
	conf, err := config.LoadConfig()
	if err != nil {
		logger.Printf("error loading config: %s", err)
		return err
	}

	currentDir, err := os.Getwd()
	if err != nil {
		logger.Printf("unable to get current directory: %s", err)
		return err
	}

	plugin := plugins.New(conf, tool)
	err = plugin.Exists()
	if err != nil {
		if _, ok := err.(plugins.PluginMissing); ok {
			logger.Printf("No such plugin: %s", tool)
		}
		return err
	}

	versionType, parsedVersion := toolversions.Parse(version)

	if version == "" {
		// resolve version
		toolversions, found, err := resolve.Version(conf, plugin, currentDir)
		if err != nil {
			fmt.Printf("err %#+v\n", err)
			return err
		}

		if found && len(toolversions.Versions) > 0 && installs.IsInstalled(conf, plugin, "version", toolversions.Versions[0]) {
			installPath := installs.InstallPath(conf, plugin, "version", toolversions.Versions[0])
			logger.Printf("%s", installPath)
			return nil
		}

		// not found
		msg := fmt.Sprintf("No version is set for %s; please run `asdf <global | shell | local> %s <version>`", tool, tool)
		logger.Print(msg)
		return errors.New(msg)
	}

	if version == "system" {
		logger.Printf("System version is selected")
		return errors.New("System version is selected")
	}

	if !installs.IsInstalled(conf, plugin, versionType, parsedVersion) {
		logger.Printf("Version not installed")
		return errors.New("Version not installed")
	}

	installPath := installs.InstallPath(conf, plugin, versionType, parsedVersion)
	logger.Printf("%s", installPath)

	return nil
}

func reshimToolVersion(conf config.Config, tool, version string, out io.Writer, errOut io.Writer) error {
	versionType, version := toolversions.Parse(version)
	return shims.GenerateForVersion(conf, plugins.New(conf, tool), versionType, version, out, errOut)
}

func latestForPlugin(conf config.Config, toolName, pattern string, showStatus bool) error {
	// show single plugin
	plugin := plugins.New(conf, toolName)
	latest, err := versions.Latest(plugin, pattern)
	if err != nil && err.Error() != "no latest version found" {
		fmt.Printf("unable to load latest version: %s\n", err)
		return err
	}

	if latest == "" {
		err := fmt.Errorf("No compatible versions available (%s %s)", toolName, pattern)
		fmt.Println(err.Error())
		return err
	}

	if showStatus {
		installed := installs.IsInstalled(conf, plugin, "version", latest)
		fmt.Printf("%s\t%s\t%s\n", plugin.Name, latest, installedStatus(installed))
	} else {
		fmt.Printf("%s\n", latest)
	}
	return nil
}

func installedStatus(installed bool) string {
	if installed {
		return "installed"
	}
	return "missing"
}
