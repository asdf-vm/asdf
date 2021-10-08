use path

asdf_dir = (path:dir (src)[name])
put $asdf_dir
set-env ASDF_DIR $asdf_dir

var asdf_user_shims
if (and (has-env "ASDF_DATA_DIR") (not (== $E:ASDF_DATA_DIR ""))) {
  asdf_user_shims = $E:ASDF_DATA_DIR/shims
} else {
  asdf_user_shims = $asdf_dir/shims
}

# Add asdf to PATH
for path [
  $asdf_dir/bin
  $asdf_user_shims
] {
  if (not (has-value $paths $path)) {
    paths = [$path $@paths]
    put $paths
  }
}

# Add function wrapper so we can export variables
fn asdf [command @args]{
  if (== $command "shell") {
    # source commands that need to export variables
    eval (slurp <(asdf export-shell-version elvish $@args))
  } else {
    # forward other commands to asdf script
    command asdf $command $@args
  }
}
