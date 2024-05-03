// Package cmd contains the asdf CLI command code
package cmd

import (
	"log"
	"os"

	"asdf/config"
	"asdf/plugins"

	"github.com/urfave/cli/v2"
)

const usageText = `The Multiple Runtime Version Manager.

Manage all your runtime versions with one tool!

Complete documentation is available at https://asdf-vm.com/`

// Execute defines the full CLI API and then runs it
func Execute() {
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
			// TODO: Flesh out all these commands
			{
				Name: "plugin",
				Action: func(_ *cli.Context) error {
					log.Print("Foobar")
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
						Action: func(_ *cli.Context) error {
							log.Print("Ipsum")
							return nil
						},
					},
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
	} else if pluginRepo == "" {
		// add from plugin repo
		// TODO: implement
		return cli.Exit("Not implemented yet", 1)
	}

	err := plugins.Add(conf, pluginName, pluginRepo)
	if err != nil {
		logger.Printf("error adding plugin: %s", err)
	}

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
		logger.Printf("error removing plugin: %s", err)
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
