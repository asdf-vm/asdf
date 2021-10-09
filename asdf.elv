use path

asdf_dir = (path:eval-symlinks (path:dir (path:eval-symlinks (src)[name]))"/..")
set-env ASDF_DIR $asdf_dir

var asdf_user_shims
if (and (has-env "ASDF_DATA_DIR") (not (== $E:ASDF_DATA_DIR ""))) {
  asdf_user_shims = $E:ASDF_DATA_DIR/shims
} else {
  asdf_user_shims = $asdf_dir/shims
}

# Add shims to PATH
if (not (has-value $paths $asdf_user_shims)) {
  paths = [$@paths $asdf_user_shims]
}

# Add function wrapper so we can export variables
fn asdf [command @args]{
  if (==s $command "shell") {
    # set environment variables
    parts = [($asdf_dir"/bin/asdf" export-shell-version elvish $@args)]
    set-env $parts[0] $parts[1]
  } else {
    # forward other commands to asdf script
    command $asdf_dir"/bin/asdf" $command $@args
  }
}
