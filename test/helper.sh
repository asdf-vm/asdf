. $(dirname $BATS_TEST_DIRNAME)/lib/utils.sh

prepare() {
  BASE_DIR=$(mktemp -dt asdf.XXXX)
  HOME=$BASE_DIR/home
  ASDF_DIR=$HOME/.asdf
}

clean() {
  rm -rf $BASE_DIR
  unset ASDF_DIR
}
