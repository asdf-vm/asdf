use path

if (not (has-env ASDF_DIR)) {
  set-env ASDF_DIR $E:HOME"/.asdf"
}

var asdf_shims_dir
if (and (has-env ASDF_DATA_DIR) (not (==s $E:ASDF_DATA_DIR ""))) {
  asdf_shims_dir = $E:ASDF_DATA_DIR"/shims"
} else {
  asdf_shims_dir = $E:ASDF_DIR"/shims"
}

# Append shims to PATH
if (not (has-value $paths $asdf_shims_dir)) {
  paths = [$@paths $asdf_shims_dir]
}

# Add function wrapper so we can export variables
fn asdf [command @args]{
  if (==s $command "shell") {
    # set environment variables
    parts = [($E:ASDF_DIR"/bin/asdf" export-shell-version elvish $@args)]
    if (==s $parts[0] "set-env") {
      set-env $parts[1] $parts[2]
    } elif (==s $parts[0] "unset-env") {
      unset-env $parts[1]
    }
  } else {
    # forward other commands to asdf script
    command $E:ASDF_DIR"/bin/asdf" $command $@args
  }
}
