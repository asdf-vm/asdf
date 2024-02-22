package cmd

import (
	"log"
	"os"

	"github.com/urfave/cli/v2"
)

const usageText = `The Multiple Runtime Version Manager.

Manage all your runtime versions with one tool!

Complete documentation is available at https://asdf-vm.com/`

func Execute() {
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
							log.Print("Baz")
							return nil
						},
					},
					&cli.Command{
						Name: "list",
						Action: func(cCtx *cli.Context) error {
							log.Print("Bim")
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
