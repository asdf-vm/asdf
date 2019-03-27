#!/usr/bin/env bats

load test_helpers

setup() {
  setup_asdf_dir
  install_dummy_plugin

  PROJECT_DIR=$HOME/project
  mkdir $PROJECT_DIR
}

teardown() {
  clean_asdf_dir
}

@test "install_command installs the correct version" {
  run asdf install dummy 1.1
  [ "$status" -eq 0 ]
  [ $(cat $ASDF_DIR/installs/dummy/1.1/version) = "1.1" ]
}

@test "install_command installs even if the user is terrible and does not use newlines" {
  cd $PROJECT_DIR
  echo -n 'dummy 1.2' > ".tool-versions"
  run asdf install
  [ "$status" -eq 0 ]
  [ $(cat $ASDF_DIR/installs/dummy/1.2/version) = "1.2" ]
}

@test "install_command set ASDF_CONCURRENCY" {
  run asdf install dummy 1.0
  [ "$status" -eq 0 ]
  [ -f $ASDF_DIR/installs/dummy/1.0/env ]
  run grep ASDF_CONCURRENCY $ASDF_DIR/installs/dummy/1.0/env
  [ "$status" -eq 0 ]
}

@test "install_command should work in directory containing whitespace" {
  WHITESPACE_DIR="$PROJECT_DIR/whitespace\ dir"
  mkdir -p "$WHITESPACE_DIR"
  cd "$WHITESPACE_DIR"
  echo 'dummy 1.2' >> "$WHITESPACE_DIR/.tool-versions"

  run asdf install

  [ "$status" -eq 0 ]
  [ $(cat $ASDF_DIR/installs/dummy/1.2/version) = "1.2" ]
}

@test "install_command should create a shim with asdf-plugin metadata" {
  run asdf install dummy 1.0
  [ "$status" -eq 0 ]
  [ -f $ASDF_DIR/installs/dummy/1.0/env ]
  run grep "asdf-plugin: dummy 1.0" $ASDF_DIR/shims/dummy
  [ "$status" -eq 0 ]
}

@test "install_command on two versions should create a shim with asdf-plugin metadata" {
  run asdf install dummy 1.1
  [ "$status" -eq 0 ]

  run grep "asdf-plugin: dummy 1.1" $ASDF_DIR/shims/dummy
  [ "$status" -eq 0 ]

  run grep "asdf-plugin: dummy 1.0" $ASDF_DIR/shims/dummy
  [ "$status" -eq 1 ]

  run asdf install dummy 1.0
  [ "$status" -eq 0 ]
  run grep "asdf-plugin: dummy 1.0" $ASDF_DIR/shims/dummy
  [ "$status" -eq 0 ]

  run grep "# asdf-plugin: dummy 1.0"$'\n'"# asdf-plugin: dummy 1.1" $ASDF_DIR/shims/dummy
  [ "$status" -eq 0 ]

  lines_count=$(grep "asdf-plugin: dummy 1.1" $ASDF_DIR/shims/dummy | wc -l)
  [ "$lines_count" -eq "1" ]
}

@test "install_command should not generate shim for subdir" {
  cd $PROJECT_DIR
  echo 'dummy 1.0' > $PROJECT_DIR/.tool-versions

  run asdf install
  [ "$status" -eq 0 ]
  [ -f "$ASDF_DIR/shims/dummy" ]
  [ ! -f "$ASDF_DIR/shims/subdir" ]
}

@test "install_command generated shim should pass all arguments to executable" {
  # asdf lib needed to run generated shims
  cp -rf $BATS_TEST_DIRNAME/../{bin,lib} $ASDF_DIR/

  cd $PROJECT_DIR
  echo 'dummy 1.0' > $PROJECT_DIR/.tool-versions
  run asdf install

  # execute the generated shim
  run $ASDF_DIR/shims/dummy world hello
  [ "$status" -eq 0 ]
  [ "$output" == "This is Dummy 1.0! hello world" ]
}

@test "install_command fails when the name or version are not specified" {
  run asdf install dummy
  [ "$status" -eq 1 ]
  [ "$output" = "You must specify a name and a version to install" ]
  [ ! -f $ASDF_DIR/installs/dummy/1.1/version ]

  run asdf install 1.1
  [ "$status" -eq 1 ]
  [ "$output" = "You must specify a name and a version to install" ]
  [ ! -f $ASDF_DIR/installs/dummy/1.1/version ]
}

@test "install_command uses a parent directory .tool-versions file if present" {
  # asdf lib needed to run generated shims
  cp -rf $BATS_TEST_DIRNAME/../{bin,lib} $ASDF_DIR/

  echo 'dummy 1.0' > $PROJECT_DIR/.tool-versions
  mkdir -p $PROJECT_DIR/child

  cd $PROJECT_DIR/child

  run asdf install

  # execute the generated shim
  [ "$($ASDF_DIR/shims/dummy world hello)" == "This is Dummy 1.0! hello world" ]
  [ "$status" -eq 0 ]
}

@test "install_command doesn't install system version" {
  run asdf install dummy system
  [ "$status" -eq 0 ]
  [ ! -f $ASDF_DIR/installs/dummy/system/version ]
}

@test "install command executes configured pre plugin install hook" {
  cat > $HOME/.asdfrc <<-'EOM'
pre_asdf_install_dummy = echo will install dummy $1
EOM

  run asdf install dummy 1.0
  [ "$output" == "will install dummy 1.0" ]
}

@test "install command executes configured post plugin install hook" {
  cat > $HOME/.asdfrc <<-'EOM'
post_asdf_install_dummy = echo HEY $version FROM $plugin_name
EOM

  run asdf install dummy 1.0
  [ "$output" == "HEY 1.0 FROM dummy" ]
}

@test "install_command skips comments in .tool-versions file" {
  cd $PROJECT_DIR
  echo -n '# dummy 1.2' > ".tool-versions"
  run asdf install
  [ "$status" -eq 0 ]
  [ "$output" == "" ]
  [ ! -f $ASDF_DIR/installs/dummy/1.2/version ]
}
