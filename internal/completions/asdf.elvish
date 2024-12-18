# Setup argument completions
fn arg-completer {|@argz|
  set argz = $argz[1..-1]  # strip 'asdf' and trailing empty string
  var num = (count $argz)
  if (== $num 0) {
    # list all subcommands
    find $asdf_dir'/lib/commands' -name 'command-*' | each {|cmd|
      put (re:replace '.*/command-(.*)\.bash' '${1}' $cmd)
    }
    put 'plugin'
  } else {
    if (match $argz 'current') {
      # asdf current <name>
      asdf plugin-list
    } elif (match $argz 'env') {
      # asdf env <command>
      ls-shims
    } elif (match $argz 'env' '.*') {
      # asdf env <command> [util]
      ls-executables
    } elif (match $argz 'exec') {
      # asdf exec <command>
      ls-shims
    } elif (match $argz 'global') {
      # asdf global <name>
      asdf plugin-list
    } elif (match $argz 'global' '.*') {
      # asdf global <name> <version>
      ls-installed-versions $argz[-1]
    } elif (match $argz 'install') {
      # asdf install <name>
      asdf plugin-list
    } elif (match $argz 'install' '.*') {
      # asdf install <name> <version>
      ls-all-versions $argz[-1]
    } elif (match $argz 'install' '.*' '.*') {
      # asdf install <name> <version> [--keep-download]
      put '--keep-download'
    } elif (match $argz 'latest') {
      # asdf latest <name>
      asdf plugin-list
    } elif (match $argz 'latest' '.*') {
      # asdf latest <name> [<version>]
      ls-all-versions $argz[-1]
    } elif (match $argz 'list-all') {
      # asdf list all <name>
      asdf plugin-list
    } elif (match $argz 'list-all' '.*') {
      # asdf list all <name> [<version>]
      ls-all-versions $argz[-1]
    } elif (match $argz 'list') {
      # asdf list <name>
      asdf plugin-list
    } elif (match $argz 'list' '.*') {
      # asdf list <name> [<version>]
      ls-installed-versions $argz[-1]
    } elif (match $argz 'local') {
      # asdf local <name> [-p|--parent]
      asdf plugin-list
      put '-p'
      put '--parent'
    } elif (match $argz 'local' '(-p|(--parent))') {
      # asdf local <name> [-p|--parent] <version>
      asdf plugin-list
    } elif (match $argz 'local' '.*') {
      # asdf local <name> [-p|--parent]
      # asdf local <name> <version>
      ls-installed-versions $argz[-1]
      put '-p'
      put '--parent'
    } elif (match $argz 'local' '(-p|(--parent))' '.*') {
      # asdf local [-p|--parent] <name> <version>
      ls-installed-versions $argz[-1]
    } elif (match $argz 'local' '.*' '(-p|(--parent))') {
      # asdf local <name> [-p|--parent] <version>
      ls-installed-versions $argz[-2]
    } elif (match $argz 'local' '.*' '.*') {
      # asdf local <name> <version> [-p|--parent]
      put '-p'
      put '--parent'
    } elif (or (match $argz 'plugin-add') (match $argz 'plugin' 'add')) {
      # asdf plugin add <name>
      asdf plugin-list-all | each {|line|
        put (re:replace '([^\s]+)\s+.*' '${1}' $line)
      }
    } elif (or (match $argz 'plugin-list') (match $argz 'plugin' 'list')) {
      # asdf plugin list
      put '--urls'
      put '--refs'
      put 'all'
    } elif (or (match $argz 'plugin-push') (match $argz 'plugin' 'push')) {
      # asdf plugin push <name>
      asdf plugin-list
    } elif (or (match $argz 'plugin-remove') (match $argz 'plugin' 'remove')) {
      # asdf plugin remove <name>
      asdf plugin-list
    } elif (and (>= (count $argz) 3) (match $argz[..3] 'plugin-test' '.*' '.*')) {
      # asdf plugin-test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]
      put '--asdf-plugin-gitref'
      put '--asdf-tool-version'
      ls-executables
      ls-shims
    } elif (and (>= (count $argz) 4) (match $argz[..4] 'plugin' 'test' '.*' '.*')) {
      # asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]
      put '--asdf-plugin-gitref'
      put '--asdf-tool-version'
      ls-executables
      ls-shims
    } elif (or (match $argz 'plugin-update') (match $argz 'plugin' 'update')) {
      # asdf plugin update <name>
      asdf plugin-list
      put '--all'
    } elif (match $argz 'plugin') {
      # list plugin-* subcommands
      find $asdf_dir'/lib/commands' -name 'command-plugin-*' | each {|cmd|
        put (re:replace '.*/command-plugin-(.*)\.bash' '${1}' $cmd)
      }
    } elif (match $argz 'reshim') {
      # asdf reshim <name>
      asdf plugin-list
    } elif (match $argz 'reshim' '.*') {
      # asdf reshim <name> <version>
      ls-installed-versions $argz[-1]
    } elif (match $argz 'shim-versions') {
      # asdf shim-versions <command>
      ls-shims
    } elif (match $argz 'uninstall') {
      # asdf uninstall <name>
      asdf plugin-list
    } elif (match $argz 'uninstall' '.*') {
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
    } elif (match $argz 'where' '.*') {
      # asdf where <name> [<version>]
      ls-installed-versions $argz[-1]
    } elif (match $argz 'which') {
      ls-shims
    }
  }
}
