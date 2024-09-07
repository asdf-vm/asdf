// Package cmd contains the asdf CLI command code
package cmd

import (
	"errors"
	"fmt"
	"io"
	"log"
	"os"
	"strings"

	"asdf/internal/config"
	"asdf/internal/info"
	"asdf/internal/installs"
	"asdf/internal/plugins"
	"asdf/internal/shims"
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
	conf, err := config.LoadConfig()
	if err != nil {
		logger.Printf("error loading config: %s", err)
		return err
	}

	err = plugins.Remove(conf, pluginName)
	if err != nil {
		// Needed to match output of old version
		logger.Printf("%s", err)
	}
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
			parsedVersion, query := parseInstallVersion(version)

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

func parseInstallVersion(version string) (string, string) {
	segments := strings.Split(version, ":")
	if len(segments) > 1 && segments[0] == "latest" {
		// Must be latest with filter
		return "latest", segments[1]
	}

	return version, ""
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

func reshimToolVersion(conf config.Config, tool, version string, out io.Writer, errOut io.Writer) error {
	versionType, version := versions.ParseString(version)
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
