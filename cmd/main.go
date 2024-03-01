package cmd

import (
	"asdf/config"
	"asdf/plugins"
	"log"
	"os"

	"github.com/urfave/cli/v2"
)

const usageText = `The Multiple Runtime Version Manager.

Manage all your runtime versions with one tool!

Complete documentation is available at https://asdf-vm.com/`

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
			&cli.Author{
				Name: "Trevor Brown",
			},
		},
		Usage:     "The multiple runtime version manager",
		UsageText: usageText,
		Commands: []*cli.Command{
			// TODO: Flesh out all these commands
			&cli.Command{
				Name: "plugin",
				Action: func(cCtx *cli.Context) error {
					log.Print("Foobar")
					return nil
				},
				Subcommands: []*cli.Command{
					&cli.Command{
						Name: "add",
						Action: func(cCtx *cli.Context) error {
							args := cCtx.Args()
							conf, err := config.LoadConfig()
							if err != nil {
								logger.Printf("error loading config: %s", err)
							}

							return pluginAddCommand(cCtx, conf, logger, args.Get(0), args.Get(1))
						},
					},
					&cli.Command{
						Name: "list",
						Action: func(cCtx *cli.Context) error {
							return nil
						},
					},
					&cli.Command{
						Name: "Lorem",
						Action: func(cCtx *cli.Context) error {
							log.Print("Foobar")
							return nil
						},
					},
					&cli.Command{
						Name: "update",
						Action: func(cCtx *cli.Context) error {
							log.Print("Ipsum")
							return nil
						},
					},
				},
			},
		},
		Action: func(cCtx *cli.Context) error {
			// TODO: flesh this out
			log.Print("Late but latest -- Rajinikanth")
			return nil
		},
	}

	err := app.Run(os.Args)

	if err != nil {
		os.Exit(1)
		log.Fatal(err)
	}
}

func pluginAddCommand(cCtx *cli.Context, conf config.Config, logger *log.Logger, pluginName, pluginRepo string) error {
	if pluginName == "" {
		// Invalid arguments
		// Maybe one day switch this to show the generated help
		// cli.ShowSubcommandHelp(cCtx)
		return cli.Exit("usage: asdf plugin add <name> [<git-url>]", 1)
	} else if pluginRepo == "" {
		// add from plugin repo
		// TODO: implement
		return cli.Exit("Not implemented yet", 1)
	} else {
		err := plugins.PluginAdd(conf, pluginName, pluginRepo)
		if err != nil {
			logger.Printf("error adding plugin: %s", err)
		}
	}
	return nil
}
