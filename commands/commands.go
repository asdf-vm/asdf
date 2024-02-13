package commands

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:   "asdf",
	Short: "The multiple runtime version manager",
	Long: `The Multiple Runtime Version Manager.

Manage all your runtime versions with one tool!

Complete documentation is available at https://asdf-vm.com/`,
	Run: func(cmd *cobra.Command, args []string) {
		// TODO: Flesh this out
		fmt.Println("Late but latest -- Rajinikanth")
	},
}

func init() {
	// TODO: Add flags relevant to all commands
	//rootCmd.PersistentFlags().BoolVarP(&Verbose, "verbose", "v", false, "verbose output")

	// TODO: Add sub commands
	//rootCmd.AddCommand(pluginCmd)
}

func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
