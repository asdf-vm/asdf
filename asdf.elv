use path

var asdf_dir = $E:HOME'/.asdf'
if (and (has-env ASDF_DIR) (!=s $E:ASDF_DIR '')) {
  asdf_dir = $E:ASDF_DIR
}

var asdf_data_dir = $asdf_dir
if (and (has-env ASDF_DATA_DIR) (!=s $E:ASDF_DATA_DIR '')) {
  asdf_data_dir = $E:ASDF_DATA_DIR
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
