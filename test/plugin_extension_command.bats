#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin
}

teardown() {
  clean_asdf_dir
}

@test "asdf can execute plugin bin commands" {
  plugin_path="$(get_plugin_path dummy)"

  # this plugin defines a new `asdf dummy foo` command
  cat <<'EOF' > "$plugin_path/bin/command-foo"
#!/usr/bin/env bash
echo this is an executable $*
EOF
  chmod +x "$plugin_path/bin/command-foo"

  expected="this is an executable bar"

  run asdf dummy foo bar
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}

@test "asdf can source plugin bin scripts" {
  plugin_path="$(get_plugin_path dummy)"

  # this plugin defines a new `asdf dummy foo` command
  echo 'echo sourced script has asdf utils $(get_plugin_path dummy) $*' > "$plugin_path/bin/command-foo"

  expected="sourced script has asdf utils $plugin_path bar"

  run asdf dummy foo bar
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}

@test "asdf can execute plugin default command without arguments" {
  plugin_path="$(get_plugin_path dummy)"

  # this plugin defines a new `asdf dummy` command
  cat <<'EOF' > "$plugin_path/bin/command"
#!/usr/bin/env bash
echo hello
EOF
  chmod +x "$plugin_path/bin/command"

  expected="hello"

  run asdf dummy
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}

@test "asdf can execute plugin default command with arguments" {
  plugin_path="$(get_plugin_path dummy)"

  # this plugin defines a new `asdf dummy` command
  cat <<'EOF' > "$plugin_path/bin/command"
#!/usr/bin/env bash
echo hello $*
EOF
  chmod +x "$plugin_path/bin/command"

  expected="hello world"

  run asdf dummy world
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}
