## Uninstalling asdf

1. In your `.bashrc` (or `.bash_profile` if you are on OSX) or `.zshrc` find the lines that source `asdf.sh` and the autocompletions. The lines should look something like this:

        . $HOME/.asdf/asdf.sh
        . $HOME/.asdf/completions/asdf.bash

    Remove these lines and save the file.
2. Run `rm -rf ~/.asdf/` to completely remove all the asdf files from your system.

That's it!
