setup_suite() {
  # Unset ASDF_DIR because it may already be set by the users shell, and some
  # tests fail when it is set to something other than the temp dir.
  unset ASDF_DIR

  # Also unset below variables, because in users shell shimmed commands
  # (include bats) export them by determining user's real HOME.
  unset ASDF_DATA_DIR
  unset ASDF_CONFIG_FILE

  # Set an agnostic Git configuration directory to prevent personal
  # configuration from interfering with the tests
  export GIT_CONFIG_GLOBAL=/dev/null
}
