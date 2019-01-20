#!/usr/bin/env bats

load test_helpers

. $(dirname $BATS_TEST_DIRNAME)/lib/commands/reshim.sh
. $(dirname $BATS_TEST_DIRNAME)/lib/commands/install.sh

setup() {
  setup_asdf_dir
  install_dummy_plugin

  PROJECT_DIR=$HOME/project
  mkdir -p $PROJECT_DIR
  cd $PROJECT_DIR

  # asdf lib needed to run generated shims
  cp -rf $BATS_TEST_DIRNAME/../{bin,lib} $ASDF_DIR/
}

teardown() {
  clean_asdf_dir
}

@test "asdf exec should pass all arguments to executable" {
  echo "dummy 1.0" > $PROJECT_DIR/.tool-versions
  run install_command

  run $ASDF_DIR/bin/asdf exec dummy world hello
  [ "$output" == "This is Dummy 1.0! hello world" ]
  [ "$status" -eq 0 ]
}

@test "shim exec should pass all arguments to executable" {
  echo "dummy 1.0" > $PROJECT_DIR/.tool-versions
  run install_command

  run $ASDF_DIR/shims/dummy world hello
  [ "$output" == "This is Dummy 1.0! hello world" ]
  [ "$status" -eq 0 ]
}

@test "shim exec should pass stdin to executable" {
  echo "dummy 1.0" > $PROJECT_DIR/.tool-versions
  run install_command

  echo "tr [:lower:] [:upper:]" > $ASDF_DIR/installs/dummy/1.0/bin/upper
  chmod +x $ASDF_DIR/installs/dummy/1.0/bin/upper

  run reshim_command dummy 1.0

  run echo $(echo hello | $ASDF_DIR/shims/upper)
  [ "$output" == "HELLO" ]
  [ "$status" -eq 0 ]
}

@test "shim exec should fail if no version is selected" {
  run install_command dummy 1.0

  touch $PROJECT_DIR/.tool-versions

  run $ASDF_DIR/shims/dummy world hello
  [ "$status" -eq 126 ]
  echo "$output" | grep -q "No version set for command dummy" 2>/dev/null
}

@test "shim exec should suggest which plugin to use when no version is selected" {
  run install_command dummy 1.0
  run install_command dummy 2.0

  touch $PROJECT_DIR/.tool-versions

  run $ASDF_DIR/shims/dummy world hello
  [ "$status" -eq 126 ]

  echo "$output" | grep -q "No version set for command dummy" 2>/dev/null
  echo "$output" | grep -q "you might want to add one of the following in your .tool-versions file" 2>/dev/null
  echo "$output" | grep -q "dummy 1.0" 2>/dev/null
  echo "$output" | grep -q "dummy 2.0" 2>/dev/null
}

@test "shim exec should suggest different plugins providing same tool when no version is selected" {
  # Another fake plugin with 'dummy' executable
  cp -rf $ASDF_DIR/plugins/dummy $ASDF_DIR/plugins/mummy

  run install_command dummy 1.0
  run install_command mummy 3.0

  touch $PROJECT_DIR/.tool-versions

  run $ASDF_DIR/shims/dummy world hello
  [ "$status" -eq 126 ]

  echo "$output" | grep -q "No version set for command dummy" 2>/dev/null
  echo "$output" | grep -q "you might want to add one of the following in your .tool-versions file" 2>/dev/null
  echo "$output" | grep -q "dummy 1.0" 2>/dev/null
  echo "$output" | grep -q "mummy 3.0" 2>/dev/null
}

@test "shim exec should execute first plugin that is installed and set" {
  run install_command dummy 3.0

  echo "dummy 1.0" > $PROJECT_DIR/.tool-versions
  echo "dummy 3.0" >> $PROJECT_DIR/.tool-versions
  echo "dummy 2.0" >> $PROJECT_DIR/.tool-versions

  run $ASDF_DIR/shims/dummy world hello
  [ "$status" -eq 0 ]

  echo "$output" | grep -q "This is Dummy 3.0! hello world" 2>/dev/null
}

@test "shim exec should determine correct executable on two projects using different plugins that provide the same tool" {
  # Another fake plugin with 'dummy' executable
  cp -rf $ASDF_DIR/plugins/dummy $ASDF_DIR/plugins/mummy
  sed -i -e 's/Dummy/Mummy/' $ASDF_DIR/plugins/mummy/bin/install

  run install_command mummy 3.0
  run install_command dummy 1.0

  mkdir $PROJECT_DIR/{A,B}
  echo "dummy 1.0" > $PROJECT_DIR/A/.tool-versions
  echo "mummy 3.0" > $PROJECT_DIR/B/.tool-versions

  cd $PROJECT_DIR/A
  run $ASDF_DIR/shims/dummy world hello
  [ "$output" == "This is Dummy 1.0! hello world" ]
  [ "$status" -eq 0 ]

  cd $PROJECT_DIR/B
  run $ASDF_DIR/shims/dummy world hello
  [ "$output" == "This is Mummy 3.0! hello world" ]
  [ "$status" -eq 0 ]
}

@test "shim exec should determine correct executable on a project with two plugins set that provide the same tool" {
  # Another fake plugin with 'dummy' executable
  cp -rf $ASDF_DIR/plugins/dummy $ASDF_DIR/plugins/mummy
  sed -i -e 's/Dummy/Mummy/' $ASDF_DIR/plugins/mummy/bin/install

  run install_command dummy 1.0
  run install_command mummy 3.0

  echo "dummy 2.0" > $PROJECT_DIR/.tool-versions
  echo "mummy 3.0" >> $PROJECT_DIR/.tool-versions
  echo "dummy 1.0" >> $PROJECT_DIR/.tool-versions

  run $ASDF_DIR/shims/dummy world hello
  [ "$output" == "This is Mummy 3.0! hello world" ]
  [ "$status" -eq 0 ]
}

@test "shim exec should fallback to system executable when specified version is system" {
  run install_command dummy 1.0

  echo "dummy system" > $PROJECT_DIR/.tool-versions

  mkdir $PROJECT_DIR/foo/
  echo "echo System" > $PROJECT_DIR/foo/dummy
  chmod +x $PROJECT_DIR/foo/dummy

  run env PATH=$PATH:$PROJECT_DIR/foo $ASDF_DIR/shims/dummy hello
  [ "$output" == "System" ]
}

@test "shim exec should execute system if set first" {
  run install_command dummy 2.0

  echo "dummy system" > $PROJECT_DIR/.tool-versions
  echo "dummy 2.0" >> $PROJECT_DIR/.tool-versions

  mkdir $PROJECT_DIR/foo/
  echo "echo System" > $PROJECT_DIR/foo/dummy
  chmod +x $PROJECT_DIR/foo/dummy

  run env PATH=$PATH:$PROJECT_DIR/foo $ASDF_DIR/shims/dummy hello
  [ "$output" == "System" ]
}

@test "shim exec should use custom exec-env for tool" {
  run install_command dummy 2.0
  echo "export FOO=sourced" > $ASDF_DIR/plugins/dummy/bin/exec-env
  mkdir $ASDF_DIR/plugins/dummy/shims
  echo 'echo $FOO custom' > $ASDF_DIR/plugins/dummy/shims/foo
  chmod +x $ASDF_DIR/plugins/dummy/shims/foo
  run reshim_command dummy 2.0

  echo "dummy 2.0" > $PROJECT_DIR/.tool-versions
  run $ASDF_DIR/shims/foo
  [ "$output" == "sourced custom" ]
}

@test "shim exec doest not use custom exec-env for system version" {
  run install_command dummy 2.0
  echo "export FOO=sourced" > $ASDF_DIR/plugins/dummy/bin/exec-env
  mkdir $ASDF_DIR/plugins/dummy/shims
  echo 'echo $FOO custom' > $ASDF_DIR/plugins/dummy/shims/foo
  chmod +x $ASDF_DIR/plugins/dummy/shims/foo
  run reshim_command dummy 2.0

  echo "dummy system" > $PROJECT_DIR/.tool-versions

  mkdir $PROJECT_DIR/sys/
  echo 'echo x$FOO System' > $PROJECT_DIR/sys/foo
  chmod +x $PROJECT_DIR/sys/foo

  run env PATH=$PATH:$PROJECT_DIR/sys $ASDF_DIR/shims/foo
  [ "$output" == "x System" ]
}

@test "shim exec should prepend the plugin paths on execution" {
  run install_command dummy 2.0

  mkdir $ASDF_DIR/plugins/dummy/shims
  echo 'which dummy' > $ASDF_DIR/plugins/dummy/shims/foo
  chmod +x $ASDF_DIR/plugins/dummy/shims/foo
  run reshim_command dummy 2.0

  echo "dummy 2.0" > $PROJECT_DIR/.tool-versions

  run $ASDF_DIR/shims/foo
  [ "$output" == "$ASDF_DIR/installs/dummy/2.0/bin/dummy" ]
}

@test "shim exec should remove shim_path from path on system version execution" {
  run install_command dummy 2.0

  echo "dummy system" > $PROJECT_DIR/.tool-versions

  mkdir $PROJECT_DIR/sys/
  echo 'which dummy' > $PROJECT_DIR/sys/dummy
  chmod +x $PROJECT_DIR/sys/dummy

  run env PATH=$PATH:$PROJECT_DIR/sys $ASDF_DIR/shims/dummy
  [ "$output" == "$PROJECT_DIR/sys/dummy" ]
}


@test "shim exec can take version from legacy file if configured" {
  run install_command dummy 2.0

  echo "legacy_version_file = yes" > $HOME/.asdfrc
  echo "2.0" > $PROJECT_DIR/.dummy-version

  run $ASDF_DIR/shims/dummy world hello
  [ "$output" == "This is Dummy 2.0! hello world" ]
}

@test "shim exec can take version from environment variable" {
  run install_command dummy 2.0
  run env ASDF_DUMMY_VERSION=2.0 $ASDF_DIR/shims/dummy world hello
  [ "$output" == "This is Dummy 2.0! hello world" ]
}

@test "shim exec uses plugin list-bin-paths" {
  exec_path="$ASDF_DIR/plugins/dummy/bin/list-bin-paths"
  custom_path="$ASDF_DIR/installs/dummy/1.0/custom"

  echo "echo bin custom" > $exec_path
  chmod +x $exec_path

  run install_command dummy 1.0
  echo "dummy 1.0" > $PROJECT_DIR/.tool-versions

  mkdir $custom_path
  echo "echo CUSTOM" > $custom_path/foo
  chmod +x $custom_path/foo

  run reshim_command dummy 1.0

  run $ASDF_DIR/shims/foo
  [ "$output" == "CUSTOM" ]
}

@test "shim exec uses plugin custom exec-path hook" {
  run install_command dummy 1.0

  exec_path="$ASDF_DIR/plugins/dummy/bin/exec-path"
  custom_dummy="$PROJECT_DIR/custom"

  echo "echo $custom_dummy" > $exec_path
  chmod +x $exec_path

  echo "echo CUSTOM" > $custom_dummy
  chmod +x $custom_dummy

  echo "dummy 1.0" > $PROJECT_DIR/.tool-versions

  run $ASDF_DIR/shims/dummy
  [ "$output" == "CUSTOM" ]
}

@test "shim exec executes configured pre-hook" {
  run install_command dummy 1.0
  echo dummy 1.0 > $PROJECT_DIR/.tool-versions

  cat > $HOME/.asdfrc <<-'EOM'
pre_dummy_dummy = echo PRE $version $1 $2
EOM

  run $ASDF_DIR/shims/dummy hello world
  [ "$status" -eq 0 ]
  echo "$output" | grep "PRE 1.0 hello world"
  echo "$output" | grep "This is Dummy 1.0! world hello"
}

@test "shim exec doesnt execute command if pre-hook failed" {
  run install_command dummy 1.0
  echo dummy 1.0 > $PROJECT_DIR/.tool-versions

  mkdir $HOME/hook
  pre_cmd="$HOME/hook/pre"
  echo 'echo $* && false' > "$pre_cmd"
  chmod +x "$pre_cmd"

  cat > $HOME/.asdfrc <<'EOM'
pre_dummy_dummy = pre $1 no $plugin_name $2
EOM

  run env PATH=$PATH:$HOME/hook $ASDF_DIR/shims/dummy hello world
  [ "$output" == "hello no dummy world" ]
  [ "$status" -eq 1 ]
}

@test "shim exec executes configured post-hook if command was successful" {
  run install_command dummy 1.0
  echo dummy 1.0 > $PROJECT_DIR/.tool-versions

  cat > $HOME/.asdfrc <<-'EOM'
post_dummy_dummy = echo POST $version $1 $2
EOM

  run $ASDF_DIR/shims/dummy hello world
  [ "$status" -eq 0 ]
  echo "$output" | grep "This is Dummy 1.0! world hello"
  echo "$output" | grep "POST 1.0 hello world"
}

@test "shim exec does not executes configured post-hook if command failed" {
  run install_command dummy 1.0
  echo dummy 1.0 > $PROJECT_DIR/.tool-versions

  cat > $HOME/.asdfrc <<-'EOM'
post_dummy_dummy = echo POST
EOM

  echo "false" > $ASDF_DIR/installs/dummy/1.0/bin/dummy
  chmod +x $ASDF_DIR/installs/dummy/1.0/bin/dummy

  run $ASDF_DIR/shims/dummy hello world
  [ "$status" -eq 1 ]
  [ "$output" == "" ]
}
