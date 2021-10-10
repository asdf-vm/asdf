
use re
use str
use path

var asdf_dir = $E:HOME'/.asdf'
if (and (has-env ASDF_DIR) (!=s $E:ASDF_DIR '')) {
  asdf_dir = $E:ASDF_DIR
} else {
  set-env ASDF_DIR $asdf_dir
}

var asdf_data_dir = $asdf_dir
if (and (has-env ASDF_DATA_DIR) (!=s $E:ASDF_DATA_DIR '')) {
  asdf_data_dir = $E:ASDF_DATA_DIR
}

# Add function wrapper so we can export variables
fn asdf [command @args]{
  if (==s $command 'shell') {
    # set environment variables
    parts = [($asdf_dir'/bin/asdf' export-shell-version elvish $@args)]
    if (==s $parts[0] 'set-env') {
      set-env $parts[1] $parts[2]
    } elif (==s $parts[0] 'unset-env') {
      unset-env $parts[1]
    }
  } else {
    # forward other commands to asdf script
    $asdf_dir'/bin/asdf' $command $@args
  }
}

fn match [argz name]{
  var num = (count $argz)
  if (== $num 0) {
    ==s $name ''
  } elif (==s $name $argz[0]) {
    == $num 1
  } else {
    ==s $name (str:join '-' $argz)
  }
}

fn match-nested [argz @pattern]{
  var matched = $true;
  if (!= (count $argz) (count $pattern)) {
    matched = $false
  } else {
    for i [(range (count $pattern))] {
      chunk = $pattern[$i]
      if (and (!=s $chunk '*') (!=s $chunk $argz[$i])) {
        matched = $false
        break
      }
    }
  }
  put $matched
}

fn ls-shims []{
  ls $asdf_data_dir'/shims'
}

fn ls-executables []{
  # Print all executable files and links in path
  try {
    find $@paths '(' -type f -o -type l ')' -print 2>/dev/null | each [p]{
      try {
        if (test -x $p) {
          path:base $p
        }
      } except {
        # don't fail if permission denied
      }
    }
  } except {
    # silence default non-zero exit status
  }
}

fn ls-installed-versions [plugin_name]{
  asdf list $plugin_name | each [version]{
    put (re:replace '^\s*(.*)\s*' '${1}' $version)
  }
}

fn ls-all-versions [plugin_name]{
  asdf list-all $plugin_name | each [version]{
    put (re:replace '^\s*(.*)\s*' '${1}' $version)
  }
}

# Append ~/.asdf/bin and ~/.asdf/shims to PATH
for path [
  $asdf_dir'/bin'
  $asdf_data_dir'/shims'
] {
  if (not (has-value $paths $path)) {
    paths = [
      $@paths
      $path
    ]
  }
}

# Setup argument completions
fn arg-completer [@argz]{
  argz = $argz[1:-1]  # strip 'asdf' and trailing empty string
  var num = (count $argz)
  if (== $num 0) {
    # list all subcommands
    find $asdf_dir'/lib/commands' -name 'command-*' | each [cmd]{
      put (re:replace '.*/command-(.*)\.bash' '${1}' $cmd)
    }
    put 'plugin'
    put 'list'
  } else {
    if (match $argz 'current') {
      # asdf current <name>
      asdf plugin-list
    } elif (match $argz 'env') {
      # asdf env <command>
      ls-shims
    } elif (match-nested $argz 'env' '*') {
      # asdf env <command> [util]
      ls-executables
    } elif (match $argz 'exec') {
      # asdf exec <command>
      ls-shims
    } elif (match $argz 'global') {
      # asdf global <name>
      asdf plugin-list
    } elif (match-nested $argz 'global' '*') {
      # asdf global <name> <version>
      ls-installed-versions $argz[-1]
    } elif (match $argz 'install') {
      # asdf install <name>
      asdf plugin-list
    } elif (match-nested $argz 'install' '*') {
      # asdf install <name> <version>
      ls-all-versions $argz[-1]
    } elif (match-nested $argz 'install' '*' '*') {
      # asdf install <name> <version> [--keep-download]
      put '--keep-download'
    } elif (match $argz 'latest') {
      # asdf latest <name>
      asdf plugin-list
    } elif (match-nested $argz 'latest' '*') {
      # asdf latest <name> [<version>]
      ls-all-versions $argz[-1]
    } elif (match $argz 'list-all') {
      # asdf list all <name>
      asdf plugin-list
    } elif (match-nested $argz 'list-all' '*') {
      # asdf list all <name> [<version>]
      ls-all-versions $argz[-1]
    } elif (match $argz 'list') {
      # asdf list <name>
      asdf plugin-list
    } elif (match-nested $argz 'list' '*') {
      # asdf list <name> [<version>]
      ls-installed-versions $argz[-1]
    } elif (match $argz 'local') {
      # asdf local <name> [-p] [--parent]
      asdf plugin-list
    } elif (match-nested $argz 'local' '*') {
      # asdf local <name> [<version>] [-p] [--parent]
      # asdf local <name> [<version>]
      ls-installed-versions $argz[-1]
      put '-p'
      put '--parent'
    } elif (match $argz 'plugin-add') {
      # asdf plugin add <name>
      asdf plugin-list-all | each [line]{
        put (re:replace '([^\s]+)\s+.*' '${1}' $line)
      }
    } elif (match $argz 'plugin-list') {
      # asdf plugin list
      put '--urls'
      put '--refs'
      put 'all'
    } elif (match $argz 'plugin-push') {
      # asdf plugin push <name>
      asdf plugin-list
    } elif (match $argz 'plugin-remove') {
      # asdf plugin remove <name>
      asdf plugin-list
    } elif (match $argz 'plugin-update') {
      # asdf plugin update <name>
      asdf plugin-list
      put '--all'
    } elif (match $argz 'plugin') {
      # list plugin-* subcommands
      find $asdf_dir'/lib/commands' -name 'command-plugin-*' | each [cmd]{
        put (re:replace '.*/command-plugin-(.*)\.bash' '${1}' $cmd)
      }
    } elif (match $argz 'reshim') {
      # asdf reshim <name>
      asdf plugin-list
    } elif (match-nested $argz 'reshim' '*') {
      # asdf reshim <name> <version>
      ls-installed-versions $argz[-1]
    } elif (match $argz 'shim-versions') {
      # asdf shim-versions <command>
      ls-shims
    } elif (match $argz 'uninstall') {
      # asdf uninstall <name>
      asdf plugin-list
    } elif (match-nested $argz 'uninstall' '*') {
      # asdf uninstall <name> <version>
      ls-installed-versions $argz[-1]
    } elif (match $argz 'update') {
      if (== $num 1) {
        # asdf update
        put '--head'
      }
    } elif (match $argz 'where') {
      # asdf where <name>
      asdf plugin-list
    } elif (match-nested $argz 'where' '*') {
      # asdf where <name> [<version>]
      ls-installed-versions $argz[-1]
    } elif (match $argz 'which') {
      ls-shims
    }
  }
}
