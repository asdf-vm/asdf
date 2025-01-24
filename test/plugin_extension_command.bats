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
  touch "$plugin_path/lib/commands/command"
  touch "$plugin_path/lib/commands/command-foo"
  touch "$plugin_path/lib/commands/command-foo-bar"
  run asdf help
  [ "$status" -eq 0 ]
  echo "$output" | grep "PLUGIN dummy" # should present plugin section
  listed_cmds=$(echo "$output" | grep -c "asdf dummy")
  [ "$listed_cmds" -eq 3 ]
  echo "$output" | grep "asdf dummy foo-bar"
}

@test "asdf help shows extension commands for plugin with hyphens in the name" {
  cd "$PROJECT_DIR"

  plugin_name=dummy-hyphenated
  install_mock_plugin $plugin_name

  plugin_path="$(get_plugin_path $plugin_name)"
  mkdir -p "$plugin_path/lib/commands"
  touch "$plugin_path/lib/commands/command"
  touch "$plugin_path/lib/commands/command-foo"
  touch "$plugin_path/lib/commands/command-foo-bar"

  run asdf help
  [ "$status" -eq 0 ]
  [[ "$output" == *"PLUGIN $plugin_name"* ]]
  listed_cmds=$(grep -c "asdf $plugin_name" <<<"${output}")
  [[ $listed_cmds -eq 3 ]]
  [[ "$output" == *"asdf $plugin_name foo"* ]]
  [[ "$output" == *"asdf $plugin_name foo-bar"* ]]
}

@test "asdf can execute plugin bin commands" {
  plugin_path="$(get_plugin_path dummy)"

  # this plugin defines a new `asdf dummy foo` command
  cat <<'EOF' >"$plugin_path/lib/commands/command-foo"
#!/usr/bin/env bash
echo this is an executable $*
EOF
  chmod +x "$plugin_path/lib/commands/command-foo"

  expected="this is an executable bar"

  run asdf cmd dummy foo bar
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}

# No longer supported. If you want to do this you'll need to manual source the
# file containing the functions you want via relative path.
#@test "asdf can source plugin bin scripts" {
#  plugin_path="$(get_plugin_path dummy)"

#  # this plugin defines a new `asdf dummy foo` command
#  echo '#!/usr/bin/env bash
#  echo sourced script has asdf utils $(get_plugin_path dummy) $*' >"$plugin_path/lib/commands/command-foo"

#  expected="sourced script has asdf utils $plugin_path bar"

#  run asdf cmd dummy foo bar
#  [ "$status" -eq 0 ]
#  [ "$output" = "$expected" ]
#}

@test "asdf can execute plugin default command without arguments" {
  plugin_path="$(get_plugin_path dummy)"

  # this plugin defines a new `asdf dummy` command
  cat <<'EOF' >"$plugin_path/lib/commands/command"
#!/usr/bin/env bash
echo hello
EOF
  chmod +x "$plugin_path/lib/commands/command"

  expected="hello"

  run asdf cmd dummy
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}

@test "asdf can execute plugin default command with arguments" {
  plugin_path="$(get_plugin_path dummy)"

  # this plugin defines a new `asdf dummy` command
  cat <<'EOF' >"$plugin_path/lib/commands/command"
#!/usr/bin/env bash
echo hello $*
EOF
  chmod +x "$plugin_path/lib/commands/command"

  expected="hello world"

  run asdf cmd dummy world
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}
