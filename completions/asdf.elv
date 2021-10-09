use re
use str
use asdf _asdf
use path

fn match [argz name]{
  try {
    var num = (count $argz)
    if (== $num 0) {
      ==s $name ''
    } elif (==s $name $argz[0]) {
      == $num 1
    } else {
      ==s $name (str:join '-' $argz)
    }
  } except err {
    echo '$err'
  }
}

fn match-nested [argz name @pattern]{
  try {
  var num_pat = (count $pattern)
  var i = 0
  var matched = $true
  if (match $argz[:(- 0 $num_pat)] $name) {
    var nested = $argz[(- 0 $num_pat):]
    if (== (count $nested) (count $pattern)) {
      for pat [$@pattern] {
        if (and (!=s $pat '*') (==s $pat $nested[$i])) {
          matched = $false
          break
        }
        i = (+ $i 1)
      }
    }
  } else {
    matched = $false
  }
  put $matched
  } except err {
    echo '$err'
  }
}

fn ls-shims []{
  ls $_asdf:asdf_data_dir'/shims'
}

fn ls-executables []{
  # Print all executable files and links in path
  try {
    find $@paths '(' -type f -o -type l ')' -print 2>/dev/null | each [p]{
      try {
        if (test -x $p) {
          path:base $p
        }
      } except { }
    }
  } except { }
}

fn ls-installed-versions [plugin_name]{
  _asdf:asdf list $plugin_name | each [version]{
    put (re:replace '^\s*(.*)\s*' '${1}' $version)
  }
}

fn ls-all-versions [plugin_name]{
  _asdf:asdf list-all $plugin_name | each [version]{
    put (re:replace '^\s*(.*)\s*' '${1}' $version)
  }
}

set edit:completion:arg-completer[asdf] = [@argz]{
  # Argument completion for for asdf

  # strip 'asdf' and trailing empty string
  argz = $argz[1:-1]
  var num = (count $argz)
  if (== $num 0) {
    # list all subcommands
    find $_asdf:asdf_dir'/lib/commands' -name 'command-*' | each [cmd]{
      put (re:replace '.*/command-(.*)\.bash' '${1}' $cmd)
    }
    put 'plugin'
    put 'list'
  } else {
    if (match $argz 'current') {
      # asdf current <name>
      _asdf:asdf plugin-list
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
      _asdf:asdf plugin-list
    } elif (match-nested $argz 'global' '*') {
      # asdf global <name> <version>
      ls-installed-versions $argz[-1]
    } elif (match $argz 'install') {
      # asdf install <name>
      _asdf:asdf plugin-list
    } elif (match-nested $argz 'install' '*') {
      # asdf install <name> <version>
      ls-all-versions $argz[-1]
    } elif (match $argz 'latest') {
      # asdf latest <name>
      _asdf:asdf plugin-list
    } elif (match-nested $argz 'latest' '*') {
      # asdf latest <name> [<version>]
      ls-all-versions $argz[-1]
    } elif (match $argz 'list-all') {
      # asdf list all <name>
      _asdf:asdf plugin-list
    } elif (match-nested $argz 'list-all' '*') {
      # asdf list all <name> [<version>]
      ls-all-versions $argz[-1]
    } elif (match $argz 'list') {
      # asdf list <name>
      _asdf:asdf plugin-list
    } elif (match-nested $argz 'list' '*') {
      # asdf list <name> [<version>]
      ls-installed-versions $argz[-1]
    } elif (match $argz 'local') {
      # asdf local <name>
      _asdf:asdf plugin-list
    } elif (match-nested $argz 'local' '*') {
      # asdf local <name> [<version>]
      ls-installed-versions $argz[-1]
    } elif (match $argz 'plugin-add') {
      # asdf plugin add <name>
      _asdf:asdf plugin-list-all | each [line]{
        put (re:replace '([^\s]+)\s+.*' '${1}' $line)
      }
    } elif (match $argz 'plugin-list') {
      # asdf plugin list
      put '--urls'
      put '--refs'
      put 'all'
    } elif (match $argz 'plugin-push') {
      # asdf plugin push <name>
      _asdf:asdf plugin-list
    } elif (match $argz 'plugin-remove') {
      # asdf plugin remove <name>
      _asdf:asdf plugin-list
    } elif (match $argz 'plugin-update') {
      # asdf plugin update <name>
      _asdf:asdf plugin-list
      put '--all'
    } elif (match $argz 'plugin') {
      # list plugin-* subcommands
      find $_asdf:asdf_dir'/lib/commands' -name 'command-plugin-*' | each [cmd]{
        put (re:replace '.*/command-plugin-(.*)\.bash' '${1}' $cmd)
      }
    } elif (match $argz 'reshim') {
      # asdf reshim <name>
      _asdf:asdf plugin-list
    } elif (match-nested $argz 'reshim' '*') {
      # asdf reshim <name> <version>
      ls-installed-versions $argz[-1]
    } elif (match $argz 'shim-versions') {
      # asdf shim-versions <command>
      ls-shims
    } elif (match $argz 'uninstall') {
      # asdf uninstall <name>
      _asdf:asdf plugin-list
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
      _asdf:asdf plugin-list
    } elif (match-nested $argz 'where' '*') {
      # asdf where <name> [<version>]
      ls-installed-versions $argz[-1]
    } elif (match $argz 'which') {
      ls-shims
    }
  }
}
