#!/usr/bin/env bash

mkdir -p "$ASDF_INSTALL_PATH"
env >"$ASDF_INSTALL_PATH/env"
echo "$ASDF_INSTALL_VERSION" >"$ASDF_INSTALL_PATH/version"

# create the dummy executable
mkdir -p "$ASDF_INSTALL_PATH/bin"
cat <<EOF >"$ASDF_INSTALL_PATH/bin/dummy"
echo This is Dummy ${ASDF_INSTALL_VERSION}! \$2 \$1
EOF
chmod +x "$ASDF_INSTALL_PATH/bin/dummy"
mkdir -p "$ASDF_INSTALL_PATH/bin/subdir"
cat <<EOF >"$ASDF_INSTALL_PATH/bin/subdir/other_bin"
echo This is Other Bin ${ASDF_INSTALL_VERSION}! \$2 \$1
EOF
chmod +x "$ASDF_INSTALL_PATH/bin/subdir/other_bin"
