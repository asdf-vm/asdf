. $(dirname $BATS_TEST_DIRNAME)/lib/utils.sh

setup_asdf_dir() {
  BASE_DIR=$(mktemp -dt asdf.XXXX)
  HOME=$BASE_DIR/home
  ASDF_DIR=$HOME/.asdf
  mkdir -p $ASDF_DIR/plugins
  mkdir -p $ASDF_DIR/installs
}

install_dummy_plugin() {
  cp -r $BATS_TEST_DIRNAME/fixtures/dummy_plugin $ASDF_DIR/plugins/dummy
}

clean_asdf_dir() {
  rm -rf $BASE_DIR
  unset ASDF_DIR
}
