#!/usr/bin/env bats

load test_helpers

. $(dirname $BATS_TEST_DIRNAME)/lib/commands/reshim.sh
. $(dirname $BATS_TEST_DIRNAME)/lib/commands/install.sh

setup() {
  setup_asdf_dir
  install_dummy_plugin

  PROJECT_DIR=$HOME/project
  mkdir $PROJECT_DIR
}

teardown() {
  clean_asdf_dir
}


@test "reshim command should remove shims of removed binaries" {
  run install_command dummy 1.0
  [ "$status" -eq 0 ]
  [ -f "$ASDF_DIR/shims/dummy" ]

  run reshim_command dummy
  [ "$status" -eq 0 ]
  [ -f "$ASDF_DIR/shims/dummy" ]

  run rm "$ASDF_DIR/installs/dummy/1.0/bin/dummy"
  run reshim_command dummy
  [ "$status" -eq 0 ]
  [ ! -f "$ASDF_DIR/shims/dummy" ]
}

@test "reshim should remove metadata of removed binaries" {
  run install_command dummy 1.0
  run install_command dummy 1.1

  run rm "$ASDF_DIR/installs/dummy/1.0/bin/dummy"
  run reshim_command dummy
  [ "$status" -eq 0 ]
  [ -f "$ASDF_DIR/shims/dummy" ]
  run grep "asdf-plugin: dummy 1.0" "$ASDF_DIR/shims/dummy"
  [ "$status" -eq 1 ]
  run grep "asdf-plugin: dummy 1.1" "$ASDF_DIR/shims/dummy"
  [ "$status" -eq 0 ]
}

@test "reshim should not duplicate shims" {
  cd $PROJECT_DIR

  run install_command dummy 1.0
  run install_command dummy 1.1
  [ "$status" -eq 0 ]
  [ -f "$ASDF_DIR/shims/dummy" ]

  run rm $ASDF_DIR/shims/*
  [ "$status" -eq 0 ]
  [ "0" -eq "$(ls $ASDF_DIR/shims/dummy* | wc -l)" ]

  run reshim_command dummy
  [ "$status" -eq 0 ]
  [ "1" -eq "$(ls $ASDF_DIR/shims/dummy* | wc -l)" ]

  run reshim_command dummy
  [ "$status" -eq 0 ]
  [ "1" -eq "$(ls $ASDF_DIR/shims/dummy* | wc -l)" ]
}

@test "reshim should create shims only for files and not folders" {
  cd $PROJECT_DIR

  run install_command dummy 1.0
  run install_command dummy 1.1
  [ "$status" -eq 0 ]
  [ -f "$ASDF_DIR/shims/dummy" ]
  [ ! -f "$ASDF_DIR/shims/subdir" ]

  run rm $ASDF_DIR/shims/*
  [ "$status" -eq 0 ]
  [ "0" -eq "$(ls $ASDF_DIR/shims/dummy* | wc -l)" ]
  [ "0" -eq "$(ls $ASDF_DIR/shims/subdir* | wc -l)" ]

  run reshim_command dummy
  [ "$status" -eq 0 ]
  [ "1" -eq "$(ls $ASDF_DIR/shims/dummy* | wc -l)" ]
  [ "0" -eq "$(ls $ASDF_DIR/shims/subdir* | wc -l)" ]

}

@test "reshim without arguments reshims all installed plugins" {
  run install_command dummy 1.0
  run rm $ASDF_DIR/shims/*
  [ "$status" -eq 0 ]
  [ "0" -eq "$(ls $ASDF_DIR/shims/dummy* | wc -l)" ]
  run reshim_command
  [ "$status" -eq 0 ]
  [ "1" -eq "$(ls $ASDF_DIR/shims/dummy* | wc -l)" ]
}

@test "reshim command executes configured pre hook" {
  run install_command dummy 1.0

  cat > $HOME/.asdfrc <<-'EOM'
pre_asdf_reshim_dummy = echo RESHIM
EOM

  run reshim_command dummy 1.0
  [ "$output" == "RESHIM" ]
}

@test "reshim command executes configured post hook" {
  run install_command dummy 1.0

  cat > $HOME/.asdfrc <<-'EOM'
post_asdf_reshim_dummy = echo RESHIM
EOM

  run reshim_command dummy 1.0
  [ "$output" == "RESHIM" ]
}
