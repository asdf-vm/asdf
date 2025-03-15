// Package cli contains the asdf CLI command code
package cli

import (
	"errors"
	"fmt"
	"io"
	"io/fs"
	"log"
	"os"
	"path/filepath"
	"slices"
	"strings"
	"text/tabwriter"

	"github.com/asdf-vm/asdf/internal/cli/set"
	"github.com/asdf-vm/asdf/internal/completions"
	"github.com/asdf-vm/asdf/internal/config"
	"github.com/asdf-vm/asdf/internal/exec"
	"github.com/asdf-vm/asdf/internal/execenv"
	"github.com/asdf-vm/asdf/internal/execute"
	"github.com/asdf-vm/asdf/internal/help"
	"github.com/asdf-vm/asdf/internal/hook"
	"github.com/asdf-vm/asdf/internal/info"
	"github.com/asdf-vm/asdf/internal/installs"
	"github.com/asdf-vm/asdf/internal/pluginindex"
	"github.com/asdf-vm/asdf/internal/plugins"
	"github.com/asdf-vm/asdf/internal/resolve"
	"github.com/asdf-vm/asdf/internal/shims"
	"github.com/asdf-vm/asdf/internal/toolversions"
	"github.com/asdf-vm/asdf/internal/versions"
	"github.com/urfave/cli/v2"
)

const usageText = `The Multiple Runtime Version Manager.

Manage all your runtime versions with one tool!

Complete documentation is available at https://asdf-vm.com/`

const updateCommandRemovedText = `
Upgrading asdf via asdf update is no longer supported. Please use your OS
package manager (Homebrew, APT, etc...) to upgrade asdf or download the
latest asdf binary manually from the asdf website.

Please visit https://asdf-vm.com/ or https://github.com/asdf-vm/asdf for more
details.`

// Execute defines the full CLI API and then runs it
func Execute(version string) {
	logger := log.New(os.Stderr, "", 0)
	log.SetFlags(0)

	app := &cli.App{
		Name:    "asdf",
		Version: version,
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
				Name: "cmd",
				Action: func(cCtx *cli.Context) error {
					args := cCtx.Args().Slice()

					return extensionCommand(logger, args)
				},
			},
			{
				Name: "completion",
				Action: func(cCtx *cli.Context) error {
					shell := cCtx.Args().Get(0)
					return completionCommand(logger, shell)
				},
			},
			{
				Name: "current",
				Flags: []cli.Flag{
					&cli.BoolFlag{
						Name:  "no-header",
						Usage: "Whether or not to print a header line",
					},
				},
				Action: func(cCtx *cli.Context) error {
					tool := cCtx.Args().Get(0)

					noHeader := cCtx.Bool("no-header")
					return currentCommand(logger, tool, noHeader)
				},
			},
			{
				Name: "env",
				Action: func(cCtx *cli.Context) error {
					shimmedCommand := cCtx.Args().Get(0)
					args := cCtx.Args().Slice()

					return envCommand(logger, shimmedCommand, args)
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
						return fmt.Errorf("error loading config: %w", err)
					}

					return infoCommand(conf, version)
				},
			},
			{
				Name: "version",
				Action: func(_ *cli.Context) error {
					fmt.Fprintf(os.Stdout, "%s\n", version)
					return nil
				},
			},
			{
				Name: "install",
				Flags: []cli.Flag{
					&cli.BoolFlag{
						Name:  "keep-download",
						Usage: "Whether or not to keep download directory after successful install",
					},
				},
				Action: func(cCtx *cli.Context) error {
					args := cCtx.Args()
					keepDownload := cCtx.Bool("keep-download")
					return installCommand(logger, args.Get(0), args.Get(1), keepDownload)
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
					cli.OsExiter(1)
					return nil
				},
				Subcommands: []*cli.Command{
					{
						Name: "add",
						Action: func(cCtx *cli.Context) error {
							args := cCtx.Args()
							conf, err := config.LoadConfig()
							if err != nil {
								return fmt.Errorf("error loading config: %w", err)
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
						Subcommands: []*cli.Command{
							{
								Name: "all",
								Action: func(_ *cli.Context) error {
									return pluginListAllCommand(logger)
								},
							},
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
					{
						Name: "test",
						Flags: []cli.Flag{
							&cli.StringFlag{
								Name:  "asdf-tool-version",
								Usage: "The tool version to use during testing",
							},
							&cli.StringFlag{
								Name:  "asdf-plugin-gitref",
								Usage: "The plugin Git ref to test",
							},
						},
						Action: func(cCtx *cli.Context) error {
							toolVersion := cCtx.String("asdf-tool-version")
							gitRef := cCtx.String("asdf-plugin-gitref")
							args := cCtx.Args().Slice()
							pluginTestCommand(logger, args, toolVersion, gitRef)
							return nil
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
				Name: "set",
				Flags: []cli.Flag{
					&cli.BoolFlag{
						Name:    "home",
						Aliases: []string{"u"},
						Usage:   "The version should be set in the current users home directory",
					},
					&cli.BoolFlag{
						Name:    "parent",
						Aliases: []string{"p"},
						Usage:   "The version should be set in the closest existing .tool-versions file in a parent directory",
					},
				},
				Action: func(cCtx *cli.Context) error {
					args := cCtx.Args().Slice()
					home := cCtx.Bool("home")
					parent := cCtx.Bool("parent")
					return set.Main(os.Stdout, os.Stderr, args, home, parent, func() (string, error) {
						return os.UserHomeDir()
					})
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
				Name: "update",
				Action: func(_ *cli.Context) error {
					fmt.Println(updateCommandRemovedText)
					return errors.New("command removed")
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
		CommandNotFound: func(_ *cli.Context, s string) {
			logger.Printf("invalid command provided: %s\n\n", s)
			helpCommand(logger, version, "", "")
			cli.OsExiter(1)
		},
	}

	if err := unsetAsdfReservedEnvVars(); err != nil {
		logger.Println("failed to unset reserved environment variables: %w", err)
		cli.OsExiter(1)
	}

	if err := app.Run(os.Args); err != nil {
		logger.Println(err)
		cli.OsExiter(1)
	}
}

func completionCommand(l *log.Logger, shell string) error {
	file, ok := completions.Get(shell)
	if !ok {
		l.Printf(`No completions available for shell with name %q
Completions are available for: %v`, shell, strings.Join(completions.Names(), ", "))
		return errors.New("bad shell name")
	}
	defer file.Close()

	io.Copy(os.Stdout, file)

	return nil
}

// This function is a whole mess and needs to be refactored
func currentCommand(logger *log.Logger, tool string, noHeader bool) error {
	conf, err := config.LoadConfig()
	if err != nil {
		return fmt.Errorf("error loading config: %w", err)
	}

	currentDir, err := os.Getwd()
	if err != nil {
		return fmt.Errorf("unable to get current directory: %w", err)
	}

	// settings here to match legacy implementation
	w := tabwriter.NewWriter(os.Stdout, 16, 0, 1, ' ', 0)
	if !noHeader {
		writeHeader(w)
	}

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
			cli.OsExiter(1)
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
		version := toolversions.Parse(firstVersion)
		installed = installs.IsInstalled(conf, plugin, version)
	}
	return toolversion, found, installed
}

func writeHeader(w *tabwriter.Writer) {
	fmt.Fprintf(w, "%s\t%s\t%s\t%s\n", "Name", "Version", "Source", "Installed")
}

func formatCurrentVersionLine(w *tabwriter.Writer, plugin plugins.Plugin, toolversion resolve.ToolVersions, found bool, installed bool, err error) error {
	if err != nil {
		return err
	}

	// columns are: name, version, source, installed
	version := formatVersions(toolversion.Versions)
	source := formatSource(toolversion, found)
	installedStatus := formatInstalled(toolversion, plugin.Name, found, installed)
	fmt.Fprintf(w, "%s\t%s\t%s\t%s\n", plugin.Name, version, source, installedStatus)
	return nil
}

func formatInstalled(toolversion resolve.ToolVersions, name string, found, installed bool) string {
	if !found {
		return ""
	}
	if !installed {
		return fmt.Sprintf("false - Run `asdf install %s %s`", name, toolversion.Versions[0])
	}
	return "true"
}

func formatSource(toolversion resolve.ToolVersions, found bool) string {
	if found {
		return filepath.Join(toolversion.Directory, toolversion.Source)
	}
	return "______"
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

func envCommand(logger *log.Logger, shimmedCommand string, args []string) error {
	command := "env"

	if shimmedCommand == "" {
		return fmt.Errorf("usage: asdf env <command>")
	}

	if len(args) >= 2 {
		command = args[1]
	}

	realArgs := []string{}
	if len(args) > 2 {
		realArgs = args[2:]
	}

	conf, err := config.LoadConfig()
	if err != nil {
		return fmt.Errorf("error loading config: %w", err)
	}

	_, plugin, version, err := getExecutable(logger, conf, shimmedCommand)
	if err != nil {
		return err
	}

	parsedVersion := toolversions.Parse(version)
	execPaths, err := shims.ExecutablePaths(conf, plugin, parsedVersion)
	if err != nil {
		return err
	}
	env := map[string]string{
		"ASDF_INSTALL_TYPE":    parsedVersion.Type,
		"ASDF_INSTALL_VERSION": parsedVersion.Value,
		"ASDF_INSTALL_PATH":    installs.InstallPath(conf, plugin, parsedVersion),
		"PATH":                 setPath(execPaths),
	}

	if parsedVersion.Type != "system" {
		env, err = execenv.Generate(plugin, env)
		if _, ok := err.(plugins.NoCallbackError); !ok && err != nil {
			return err
		}
	}

	fname, err := shims.ExecutableOnPath(env["PATH"], command)
	if err != nil {
		return err
	}

	finalEnv := execute.MergeWithCurrentEnv(env)
	err = exec.Exec(fname, realArgs, finalEnv)
	if err != nil {
		fmt.Printf("err %#+v\n", err.Error())
	}
	return err
}

func setPath(paths []string) string {
	return strings.Join(paths, ":") + ":" + os.Getenv("PATH")
}

func execCommand(logger *log.Logger, command string, args []string) error {
	if command == "" {
		return fmt.Errorf("usage: asdf exec <command>")
	}

	conf, err := config.LoadConfig()
	if err != nil {
		return fmt.Errorf("error loading config: %w", err)
	}

	executable, plugin, version, err := getExecutable(logger, conf, command)
	if err != nil {
		return err
	}

	if len(args) > 1 {
		args = args[1:]
	} else {
		args = []string{}
	}

	parsedVersion := toolversions.Parse(version)
	execPaths, err := shims.ExecutablePaths(conf, plugin, parsedVersion)
	if err != nil {
		return err
	}
	env := map[string]string{
		"ASDF_INSTALL_TYPE":    parsedVersion.Type,
		"ASDF_INSTALL_VERSION": parsedVersion.Value,
		"ASDF_INSTALL_PATH":    installs.InstallPath(conf, plugin, parsedVersion),
		"PATH":                 setPath(execPaths),
	}

	if parsedVersion.Type != "system" {
		env, err = execenv.Generate(plugin, env)
		if _, ok := err.(plugins.NoCallbackError); !ok && err != nil {
			return err
		}
	}

	err = hook.RunWithOutput(conf, fmt.Sprintf("pre_%s_%s", plugin.Name, filepath.Base(executable)), args, os.Stdout, os.Stderr)
	if err != nil {
		cli.OsExiter(1)
		return err
	}

	finalEnv := execute.MergeWithCurrentEnv(env)
	return exec.Exec(executable, args, finalEnv)
}

func extensionCommand(logger *log.Logger, args []string) error {
	if len(args) < 1 {
		return errors.New("no plugin name specified")
	}

	conf, err := config.LoadConfig()
	if err != nil {
		return fmt.Errorf("error loading config: %w", err)
	}

	pluginName := args[0]
	plugin := plugins.New(conf, pluginName)

	err = runExtensionCommand(plugin, args[1:])
	if err != nil {
		return fmt.Errorf("error running extension command: %w", err)
	}
	return nil
}

func runExtensionCommand(plugin plugins.Plugin, args []string) (err error) {
	path := ""
	if len(args) > 0 {
		path, err = plugin.ExtensionCommandPath(args[0])

		if err != nil {
			path, err = plugin.ExtensionCommandPath("")
			if err != nil {
				return err
			}
		} else {
			args = args[1:]
		}
	} else {
		path, err = plugin.ExtensionCommandPath("")
		if err != nil {
			return err
		}
	}

	return exec.Exec(path, args, os.Environ())
}

func getExecutable(logger *log.Logger, conf config.Config, command string) (executable string, plugin plugins.Plugin, version string, err error) {
	currentDir, err := os.Getwd()
	if err != nil {
		return "", plugins.Plugin{}, "", fmt.Errorf("unable to get current directory: %w", err)
	}

	executable, plugin, version, found, err := shims.FindExecutable(conf, command, currentDir)
	if err != nil {

		if _, ok := err.(shims.NoExecutableForPluginError); ok {
			logger.Printf("No executable %s found for current version. Please select a different version or install %s manually for the current version", command, command)
			cli.OsExiter(1)
			return "", plugin, version, err
		}
		shimPath := shims.Path(conf, command)
		toolVersions, _ := shims.GetToolsAndVersionsFromShimFile(shimPath)

		if len(toolVersions) > 0 {
			if anyInstalled(conf, toolVersions) {
				logger.Printf("No version is set for command %s", command)
				logger.Printf("Consider adding one of the following versions in your config file at %s/.tool-versions\n", currentDir)
			} else {
				logger.Printf("No preset version installed for command %s", command)
				for _, toolVersion := range toolVersions {
					for _, version := range toolVersion.Versions {
						fmt.Printf("asdf install %s %s\n", toolVersion.Name, version)
					}
				}

				fmt.Printf("or add one of the following versions in your config file at %s/.tool-versions\n", currentDir)
			}

			for _, toolVersion := range toolVersions {
				for _, version := range toolVersion.Versions {
					fmt.Printf("%s %s\n", toolVersion.Name, version)
				}
			}
		}

		os.Exit(126)
		return executable, plugins.Plugin{}, "", err
	}

	if !found {
		logger.Print("executable not found")
		os.Exit(126)
		return executable, plugins.Plugin{}, "", fmt.Errorf("executable not found")
	}

	return executable, plugin, version, nil
}

func anyInstalled(conf config.Config, toolVersions []toolversions.ToolVersions) bool {
	for _, toolVersion := range toolVersions {
		for _, version := range toolVersion.Versions {
			version := toolversions.Parse(version)
			plugin := plugins.New(conf, toolVersion.Name)
			if installs.IsInstalled(conf, plugin, version) {
				return true
			}
		}
	}
	return false
}

func pluginAddCommand(_ *cli.Context, conf config.Config, logger *log.Logger, pluginName, pluginRepo string) error {
	if pluginName == "" {
		// Invalid arguments
		// Maybe one day switch this to show the generated help
		// cli.ShowSubcommandHelp(cCtx)
		return fmt.Errorf("usage: asdf plugin add <name> [<git-url>]")
	}

	err := plugins.Add(conf, pluginName, pluginRepo, "")
	if err != nil {
		var existsErr plugins.PluginAlreadyExists
		if errors.As(err, &existsErr) {
			// This is considered a success case
			return nil
		}
		return err
	}

	return nil
}

func pluginRemoveCommand(_ *cli.Context, logger *log.Logger, pluginName string) error {
	if pluginName == "" {
		return fmt.Errorf("no plugin given")
	}

	conf, err := config.LoadConfig()
	if err != nil {
		return fmt.Errorf("error loading config: %w", err)
	}

	err = plugins.Remove(conf, pluginName, os.Stdout, os.Stderr)
	if err != nil {
		return fmt.Errorf("error removing plugin: %w", err)
	}

	// This feels a little hacky but it works, to re-generate shims we delete them
	// all and generate them again.
	err = shims.RemoveAll(conf)
	if err != nil {
		return fmt.Errorf("error removing shims: %w", err)
	}

	err = shims.GenerateAll(conf, os.Stdout, os.Stderr)
	if err != nil {
		return fmt.Errorf("error generating shims: %w", err)
	}

	return nil
}

func pluginListCommand(cCtx *cli.Context, logger *log.Logger) error {
	urls := cCtx.Bool("urls")
	refs := cCtx.Bool("refs")

	conf, err := config.LoadConfig()
	if err != nil {
		return fmt.Errorf("error loading config: %w", err)
	}

	plugins, err := plugins.List(conf, urls, refs)
	if err != nil {
		return fmt.Errorf("error loading plugin list: %w", err)
	}

	if len(plugins) == 0 {
		fmt.Println("No plugins installed")
		return nil
	}

	// TODO: Add some sort of presenter logic in another file so we
	// don't clutter up this cmd code with conditional presentation
	// logic
	for _, plugin := range plugins {
		if urls && refs {
			fmt.Printf("%s\t\t%s\t%s\n", plugin.Name, plugin.URL, plugin.Ref)
		} else if refs {
			fmt.Printf("%s\t\t%s\n", plugin.Name, plugin.Ref)
		} else if urls {
			fmt.Printf("%s\t\t%s\n", plugin.Name, plugin.URL)
		} else {
			fmt.Printf("%s\n", plugin.Name)
		}
	}

	return nil
}

func pluginListAllCommand(logger *log.Logger) error {
	conf, err := config.LoadConfig()
	if err != nil {
		return fmt.Errorf("error loading config: %w", err)
	}

	disableRepo, err := conf.DisablePluginShortNameRepository()
	if err != nil {
		return fmt.Errorf("unable to check config: %w", err)
	}
	if disableRepo {
		return fmt.Errorf("short-name plugin repository is disabled")
	}

	lastCheckDuration := 0
	// We don't care about errors here as we can use the default value
	checkDuration, _ := conf.PluginRepositoryLastCheckDuration()

	if !checkDuration.Never {
		lastCheckDuration = checkDuration.Every
	}

	index := pluginindex.Build(conf.DataDir, conf.PluginIndexURL, false, lastCheckDuration)
	availablePlugins, err := index.Get()
	if err != nil {
		return fmt.Errorf("error loading plugin index: %w", err)
	}

	installedPlugins, err := plugins.List(conf, true, false)
	if err != nil {
		return fmt.Errorf("error loading plugin list: %w", err)
	}

	w := tabwriter.NewWriter(os.Stdout, 15, 0, 1, ' ', 0)
	for _, availablePlugin := range availablePlugins {
		if pluginInstalled(availablePlugin, installedPlugins) {
			fmt.Fprintf(w, "%s\t\t*%s\n", availablePlugin.Name, availablePlugin.URL)
		} else {
			fmt.Fprintf(w, "%s\t\t%s\n", availablePlugin.Name, availablePlugin.URL)
		}
	}
	w.Flush()

	return nil
}

func pluginInstalled(plugin pluginindex.Plugin, installedPlugins []plugins.Plugin) bool {
	for _, installedPlugin := range installedPlugins {
		if installedPlugin.Name == plugin.Name && installedPlugin.URL == plugin.URL {
			return true
		}
	}

	return false
}

func infoCommand(conf config.Config, version string) error {
	return info.Print(conf, version)
}

func helpCommand(logger *log.Logger, asdfVersion, tool, version string) error {
	conf, err := config.LoadConfig()
	if err != nil {
		return fmt.Errorf("error loading config: %w", err)
	}

	if tool != "" {
		if version != "" {
			err := help.PrintToolVersion(conf, tool, version)
			if err != nil {
				cli.OsExiter(1)
			}
			return err
		}

		err := help.PrintTool(conf, tool)
		if err != nil {
			cli.OsExiter(1)
		}
		return err
	}

	allPlugins, err := plugins.List(conf, false, false)
	if err != nil {
		cli.OsExiter(1)
	}

	err = help.Print(asdfVersion, allPlugins)
	if err != nil {
		cli.OsExiter(1)
	}

	return err
}

func pluginUpdateCommand(cCtx *cli.Context, logger *log.Logger, pluginName, ref string) error {
	updateAll := cCtx.Bool("all")
	if !updateAll && pluginName == "" {
		return fmt.Errorf("usage: asdf plugin update {<name> [git-ref] | --all}")
	}

	conf, err := config.LoadConfig()
	if err != nil {
		return fmt.Errorf("error loading config: %w", err)
	}

	if updateAll {
		installedPlugins, err := plugins.List(conf, false, false)
		if err != nil {
			return fmt.Errorf("failed to get plugin list: %w", err)
		}

		var updateErrors []error
		for _, plugin := range installedPlugins {
			updatedToRef, err := plugin.Update(conf, "", os.Stdout, os.Stderr)
			if err != nil {
				updateErrors = append(updateErrors, fmt.Errorf("failed to update %s: %w", plugin.Name, err))
			} else {
				fmt.Printf("updated %s to ref %s\n", plugin.Name, updatedToRef)
			}
		}

		if len(updateErrors) > 0 {
			// Return the first error, but log all of them
			for _, err := range updateErrors {
				logger.Println(err)
			}
			return updateErrors[0]
		}
		return nil
	}

	plugin := plugins.New(conf, pluginName)
	updatedToRef, err := plugin.Update(conf, ref, os.Stdout, os.Stderr)
	if err != nil {
		return fmt.Errorf("failed to update %s: %w", pluginName, err)
	}
	fmt.Printf("updated %s to ref %s\n", pluginName, updatedToRef)
	return nil
}

func pluginTestCommand(l *log.Logger, args []string, toolVersion, ref string) {
	conf, err := config.LoadConfig()
	if err != nil {
		l.Printf("error loading config: %s\n", err)
		cli.OsExiter(1)
		return
	}

	if len(args) < 2 {
		failTest(l, "please provide a plugin name and url")
	}

	name := args[0]
	url := args[1]
	testName := fmt.Sprintf("asdf-test-%s", name)

	// Install plugin
	err = plugins.Add(conf, testName, url, ref)
	if err != nil {
		failTest(l, fmt.Sprintf("%s was not properly installed", name))
	}

	// Remove plugin
	var blackhole strings.Builder
	defer plugins.Remove(conf, testName, &blackhole, &blackhole)

	// Assert callbacks are present
	plugin := plugins.New(conf, testName)
	files, err := os.ReadDir(filepath.Join(plugin.Dir, "bin"))
	if _, ok := err.(*fs.PathError); ok {
		failTest(l, "bin/ directory does not exist")
	}

	callbacks := []string{}
	for _, file := range files {
		callbacks = append(callbacks, file.Name())
	}

	for _, expectedCallback := range []string{"download", "install", "list-all"} {
		if !slices.Contains(callbacks, expectedCallback) {
			failTest(l, fmt.Sprintf("missing callback %s", expectedCallback))
		}
	}

	allCallbacks := []string{"download", "install", "list-all", "latest-stable", "help.overview", "help.deps", "help.config", "help.links", "list-bin-paths", "exec-env", "exec-path", "uninstall", "list-legacy-filenames", "parse-legacy-file", "post-plugin-add", "post-plugin-update", "pre-plugin-remove"}

	// Assert all callbacks present are executable
	for _, file := range files {
		// file is a callback...
		if slices.Contains(allCallbacks, file.Name()) {
			// check if it is executable
			info, _ := file.Info()
			if !(info.Mode()&0o111 != 0) {
				failTest(l, fmt.Sprintf("callback lacks executable permission: %s", file.Name()))
			}
		}
	}

	// Assert has license
	licensePath := filepath.Join(plugin.Dir, "LICENSE")
	if _, err := os.Stat(licensePath); errors.Is(err, os.ErrNotExist) {
		failTest(l, "LICENSE file must be present in the plugin repository")
	}

	bytes, err := os.ReadFile(licensePath)
	if err != nil {
		failTest(l, "LICENSE file must be present in the plugin repository")
	}

	// Validate license file not empty
	if len(bytes) == 0 {
		failTest(l, "LICENSE file in the plugin repository must not be empty")
	}

	// Validate it returns at least one available version
	var output strings.Builder
	err = plugin.RunCallback("list-all", []string{}, map[string]string{}, &output, &blackhole)
	if err != nil {
		failTest(l, "Unable to list available versions")
	}

	allVersions := strings.Fields(output.String())
	if len(allVersions) < 1 {
		failTest(l, "list-all did not return any version")
	}

	// grab first version returned by list-all callback if no version provided as
	// a CLI argument
	if toolVersion == "" {
		toolVersion = allVersions[0]
	}

	err = versions.InstallOneVersion(conf, plugin, toolVersion, false, os.Stdout, os.Stderr)
	if err != nil {
		failTest(l, "install exited with an error")
	}
}

func failTest(logger *log.Logger, msg string) {
	logger.Printf("FAILED: %s", msg)
	cli.OsExiter(1)
}

// formatUpdateResult has been replaced with inline error handling in pluginUpdateCommand

func installCommand(logger *log.Logger, toolName, version string, keepDownload bool) error {
	conf, err := config.LoadConfig()
	if err != nil {
		return fmt.Errorf("error loading config: %w", err)
	}

	dir, err := os.Getwd()
	if err != nil {
		return fmt.Errorf("unable to fetch current directory: %w", err)
	}

	if toolName == "" {
		// Install all versions
		errs := versions.InstallAll(conf, dir, os.Stdout, os.Stderr)
		if len(errs) > 0 {
			filtered := filterInstallErrors(errs)
			if len(filtered) > 0 {
				return fmt.Errorf("%s (and possibly other errors)", filtered[0])
			}
		}
		return nil
	}

	// Install specific version
	plugin := plugins.New(conf, toolName)

	if version == "" {
		err = versions.Install(conf, plugin, dir, os.Stdout, os.Stderr)
		if err != nil {
			var vaiErr versions.VersionAlreadyInstalledError
			if errors.As(err, &vaiErr) {
				// This is OK, just return the error
				return err
			}

			if _, ok := err.(versions.NoVersionSetError); ok {
				return fmt.Errorf("no versions specified for %s in config files or environment", toolName)
			}

			return fmt.Errorf("failed to install %s: %w", toolName, err)
		}
	} else {
		parsedVersion := toolversions.ParseFromCliArg(version)

		if parsedVersion.Type == "latest" {
			err = versions.InstallVersion(conf, plugin, parsedVersion, os.Stdout, os.Stderr)
		} else {
			// Adding this here to get tests passing. The other versions.Install*
			// calls here could have a keepDownload argument added as well. PR
			// welcome!
			err = versions.InstallOneVersion(conf, plugin, version, keepDownload, os.Stdout, os.Stderr)
		}

		if err != nil {
			var vaiErr versions.VersionAlreadyInstalledError
			if errors.As(err, &vaiErr) {
				// This is OK
				return nil
			}

			return fmt.Errorf("error installing %s version %s: %w", toolName, version, err)
		}
	}

	return nil
}

func filterInstallErrors(errs []error) []error {
	var filtered []error
	for _, err := range errs {
		var vaiErr versions.VersionAlreadyInstalledError
		if errors.As(err, &vaiErr) {
			continue
		}

		if _, ok := err.(versions.NoVersionSetError); !ok {
			filtered = append(filtered, err)
		}
	}
	return filtered
}

func latestCommand(logger *log.Logger, all bool, toolName, pattern string) (err error) {
	conf, err := config.LoadConfig()
	if err != nil {
		return fmt.Errorf("error loading config: %w", err)
	}

	if !all {
		if toolName == "" {
			return fmt.Errorf("no plugin name provided")
		}
		return latestForPlugin(conf, toolName, pattern, false)
	}

	plugins, err := plugins.List(conf, false, false)
	if err != nil {
		return fmt.Errorf("error loading plugin list: %w", err)
	}

	if len(plugins) == 0 {
		return fmt.Errorf("no plugins installed")
	}

	var errors []error
	// loop over all plugins and show latest for each one.
	for _, plugin := range plugins {
		err := latestForPlugin(conf, plugin.Name, "", true)
		if err != nil {
			errors = append(errors, fmt.Errorf("plugin %s: %w", plugin.Name, err))
		}
	}

	if len(errors) > 0 {
		// Return the first error, but all should be logged by caller
		return errors[0]
	}
	return nil
}

func listCommand(logger *log.Logger, first, second, third string) (err error) {
	conf, err := config.LoadConfig()
	if err != nil {
		return fmt.Errorf("error loading config: %w", err)
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
		return fmt.Errorf("no plugin given")
	}

	plugin, err := loadPlugin(logger, conf, toolName)
	if err != nil {
		return err
	}

	var stdout strings.Builder
	var stderr strings.Builder

	err = plugin.RunCallback("list-all", []string{}, map[string]string{}, &stdout, &stderr)
	if err != nil {
		fmt.Printf("Plugin %s's list-all callback script failed with output:\n", plugin.Name)
		// Print to stderr
		os.Stderr.WriteString(stderr.String())
		os.Stderr.WriteString(stdout.String())

		return err
	}

	versions := strings.Split(stdout.String(), " ")

	if filter != "" {
		versions = filterByExactMatch(versions, filter)
	}

	if len(versions) == 0 {
		return fmt.Errorf("no compatible versions available (%s %s)", plugin.Name, filter)
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
		return fmt.Errorf("unable to get current directory %s", err)
	}

	if pluginName != "" {
		plugin, err := loadPlugin(logger, conf, pluginName)
		if err != nil {
			return err
		}
		versions, _ := installs.Installed(conf, plugin)

		if filter != "" {
			versions = filterByExactMatch(versions, filter)
		}

		if len(versions) == 0 {
			return fmt.Errorf("no compatible versions installed (%s %s)", plugin.Name, filter)
		}

		currentVersions, _, err := resolve.Version(conf, plugin, currentDir)
		if err != nil {
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
		return fmt.Errorf("unable to list plugins due to error: %s", err)
	}

	for _, plugin := range allPlugins {
		fmt.Printf("%s\n", plugin.Name)
		versions, _ := installs.Installed(conf, plugin)

		if len(versions) > 0 {
			currentVersions, _, err := resolve.Version(conf, plugin, currentDir)
			if err != nil {
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
		return fmt.Errorf("error loading config: %w", err)
	}

	var plugin plugins.Plugin

	if tool != "" {
		plugin = plugins.New(conf, tool)
		if err := plugin.Exists(); err != nil {
			return fmt.Errorf("plugin %s not found", plugin.Name)
		}
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
	return reshimToolVersion(conf, plugin, version, os.Stdout, os.Stderr)
}

func shimVersionsCommand(logger *log.Logger, shimName string) error {
	if shimName == "" {
		return fmt.Errorf("usage: asdf shimversions <command>")
	}

	conf, err := config.LoadConfig()
	if err != nil {
		return fmt.Errorf("error loading config: %w", err)
	}

	shimPath := shims.Path(conf, shimName)
	toolVersions, err := shims.GetToolsAndVersionsFromShimFile(shimPath)
	if err == nil {
		for _, toolVersion := range toolVersions {
			for _, version := range toolVersion.Versions {
				fmt.Printf("%s %s\n", toolVersion.Name, version)
			}
		}
	}
	return err
}

// This function is a whole mess and needs to be refactored
func whichCommand(logger *log.Logger, command string) error {
	conf, err := config.LoadConfig()
	if err != nil {
		return fmt.Errorf("error loading config: %w", err)
	}

	currentDir, err := os.Getwd()
	if err != nil {
		return fmt.Errorf("unable to get current directory: %w", err)
	}

	if command == "" {
		return errors.New("usage: asdf which <command>")
	}

	path, _, _, _, err := shims.FindExecutable(conf, command, currentDir)
	if _, ok := err.(shims.UnknownCommandError); ok {
		return fmt.Errorf("unknown command: %s. Perhaps you have to reshim?", command)
	}

	if _, ok := err.(shims.NoExecutableForPluginError); ok {
		return fmt.Errorf("no executable for tool version: %w", err)
	}

	if err != nil {
		return fmt.Errorf("unexpected error: %w", err)
	}

	fmt.Printf("%s\n", path)
	return nil
}

func uninstallCommand(logger *log.Logger, tool, version string) error {
	if tool == "" || version == "" {
		return fmt.Errorf("no plugin or version given")
	}

	conf, err := config.LoadConfig()
	if err != nil {
		return fmt.Errorf("error loading config: %w", err)
	}

	plugin := plugins.New(conf, tool)
	err = versions.Uninstall(conf, plugin, version, os.Stdout, os.Stderr)
	if err != nil {
		return fmt.Errorf("error uninstalling %s %s: %w", tool, version, err)
	}

	// This feels a little hacky but it works, to re-generate shims we delete them
	// all and generate them again.
	err = shims.RemoveAll(conf)
	if err != nil {
		return fmt.Errorf("error removing shims: %w", err)
	}

	return shims.GenerateAll(conf, os.Stdout, os.Stderr)
}

func whereCommand(logger *log.Logger, tool, versionStr string) error {
	conf, err := config.LoadConfig()
	if err != nil {
		return fmt.Errorf("error loading config: %w", err)
	}

	currentDir, err := os.Getwd()
	if err != nil {
		return fmt.Errorf("unable to get current directory: %w", err)
	}

	plugin := plugins.New(conf, tool)
	err = plugin.Exists()
	if err != nil {
		if _, ok := err.(plugins.PluginMissing); ok {
			return fmt.Errorf("no such plugin: %s", tool)
		}
		return err
	}

	version := toolversions.Parse(versionStr)

	if version.Type == "system" {
		return errors.New("system version is selected")
	}

	if version.Value == "" {
		// resolve version
		versions, found, err := resolve.Version(conf, plugin, currentDir)
		if err != nil {
			return fmt.Errorf("error resolving version: %w", err)
		}

		if found && len(versions.Versions) > 0 {
			versionStruct := toolversions.Version{Type: "version", Value: versions.Versions[0]}
			if installs.IsInstalled(conf, plugin, versionStruct) {
				installPath := installs.InstallPath(conf, plugin, versionStruct)
				fmt.Printf("%s", installPath)
				return nil
			}
		}

		// not found
		return fmt.Errorf("no version is set for %s; please run `asdf set [options] %s <version>`", tool, tool)
	}

	if !installs.IsInstalled(conf, plugin, version) {
		return fmt.Errorf("version %s is not installed", version.Value)
	}

	installPath := installs.InstallPath(conf, plugin, version)
	fmt.Printf("%s", installPath)

	return nil
}

func loadPlugin(logger *log.Logger, conf config.Config, pluginName string) (plugins.Plugin, error) {
	plugin := plugins.New(conf, pluginName)
	err := plugin.Exists()
	if err != nil {
		return plugin, fmt.Errorf("no such plugin: %s", pluginName)
	}

	return plugin, nil
}

func reshimToolVersion(conf config.Config, plugin plugins.Plugin, versionStr string, out io.Writer, errOut io.Writer) error {
	version := toolversions.Parse(versionStr)

	return shims.GenerateForVersion(conf, plugin, version, out, errOut)
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
		return fmt.Errorf("no compatible versions available (%s %s)", toolName, pattern)
	}

	if showStatus {
		installed := installs.IsInstalled(conf, plugin, toolversions.Version{Type: "version", Value: latest})
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

func unsetAsdfReservedEnvVars() error {
	// These are environment variables which are passed via env or exec.
	// We strip these out to avoid any potential issues with recursive calls to asdf.
	asdfManagedVars := []string{"ASDF_INSTALL_TYPE", "ASDF_INSTALL_VERSION", "ASDF_INSTALL_PATH"}
	for _, v := range asdfManagedVars {
		err := os.Unsetenv(v)
		if err != nil {
			log.Printf("error unsetting environment variable %s: %s", v, err)
			return err
		}
	}
	return nil
}
