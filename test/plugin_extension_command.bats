#!/usr/bin/env bats
# shellcheck disable=SC2016

load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin
  local plugin_path
  plugin_path="$(get_plugin_path dummy)"
  mkdir -p "$plugin_path/lib/commands"
}

teardown() {
  clean_asdf_dir
}

@test "asdf help shows plugin extension commands" {
  local plugin_path listed_cmds
  plugin_path="$(get_plugin_path dummy)"
  touch "$plugin_path/lib/commands/command.bash"
  touch "$plugin_path/lib/commands/command-foo.bash"
  touch "$plugin_path/lib/commands/command-foo-bar.bash"
  run asdf help
  [ "$status" -eq 0 ]
  echo "$output" | grep "PLUGIN dummy" # should present plugin section
  listed_cmds=$(echo "$output" | grep -c "asdf dummy")
  [ "$listed_cmds" -eq 3 ]
  echo "$output" | grep "asdf dummy foo bar" # should present commands without hyphens
}

@test "asdf help shows extension commands for plugin with hyphens in the name" {
  cd "$PROJECT_DIR"

  plugin_name=dummy-hyphenated
  install_mock_plugin $plugin_name

  plugin_path="$(get_plugin_path $plugin_name)"
  mkdir -p "$plugin_path/lib/commands"
  touch "$plugin_path/lib/commands/command.bash"
  touch "$plugin_path/lib/commands/command-foo.bash"
  touch "$plugin_path/lib/commands/command-foo-bar.bash"

  run asdf help
  [ "$status" -eq 0 ]
  [[ "$output" == *"PLUGIN $plugin_name"* ]]
  listed_cmds=$(grep -c "asdf $plugin_name" <<<"${output}")
  [[ $listed_cmds -eq 3 ]]
  [[ "$output" == *"asdf $plugin_name foo"* ]]
  [[ "$output" == *"asdf $plugin_name foo bar"* ]]
}

@test "asdf can execute plugin bin commands" {
  plugin_path="$(get_plugin_path dummy)"

  # this plugin defines a new `asdf dummy foo` command
  cat <<'EOF' >"$plugin_path/lib/commands/command-foo.bash"
#!/usr/bin/env bash
echo this is an executable $*
EOF
  chmod +x "$plugin_path/lib/commands/command-foo.bash"

  expected="this is an executable bar"

  run asdf dummy foo bar
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}

@test "asdf can source plugin bin scripts" {
  plugin_path="$(get_plugin_path dummy)"

  # this plugin defines a new `asdf dummy foo` command
  echo 'echo sourced script has asdf utils $(get_plugin_path dummy) $*' >"$plugin_path/lib/commands/command-foo.bash"

  expected="sourced script has asdf utils $plugin_path bar"

  run asdf dummy foo bar
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}

@test "asdf can execute plugin default command without arguments" {
  plugin_path="$(get_plugin_path dummy)"

  # this plugin defines a new `asdf dummy` command
  cat <<'EOF' >"$plugin_path/lib/commands/command.bash"
#!/usr/bin/env bash
echo hello
EOF
  chmod +x "$plugin_path/lib/commands/command.bash"

  expected="hello"

  run asdf dummy
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}

@test "asdf can execute plugin default command with arguments" {
  plugin_path="$(get_plugin_path dummy)"

  # this plugin defines a new `asdf dummy` command
  cat <<'EOF' >"$plugin_path/lib/commands/command.bash"
#!/usr/bin/env bash
echo hello $*
EOF
  chmod +x "$plugin_path/lib/commands/command.bash"

  expected="hello world"

  run asdf dummy world
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}
