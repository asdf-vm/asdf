package exec

import (
	"fmt"
	"os"
	"os/exec"
	"testing"

	"github.com/rogpeppe/go-internal/testscript"
)

func execit() int {
	// Exec only works with absolute path
	cmdPath, _ := exec.LookPath(os.Args[1])
	err := Exec(cmdPath, os.Args[2:], os.Environ())
	if err != nil {
		fmt.Printf("Err: %#+v\n", err.Error())
	}

	return 0
}

func TestMain(m *testing.M) {
	os.Exit(testscript.RunMain(m, map[string]func() int{
		"execit": execit,
	}))
}

func TestExec(t *testing.T) {
	testscript.Run(t, testscript.Params{
		Dir: "testdata/script",
	})
}
