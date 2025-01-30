#!/bin/sh

# Note: we cannot assume we're running bash and use the set -euo pipefail approach.
set -e

VERSION="0.16.0"
FILE="asdf-v$VERSION"

# Include operating system in file name.
OS="$(uname -s | cut -d '-' -f 1)"
case "$OS" in
Linux)
    FILE="${FILE}-linux"
    TARGET="/usr/local/bin"
    ;;
Darwin)
    FILE="${FILE}-darwin"
    TARGET="/usr/local/bin"
    ;;
*)
    echo "Unknown operating system: $OS"
    exit 1
    ;;
esac

# Include architecture in file name.
ARCH="$(uname -m)"
case "$ARCH" in
i386)
    FILE="${FILE}-386"
    ;;
x86_64)
    FILE="${FILE}-amd64"
    ;;
arm64|aarch64)
    FILE="${FILE}-arm64"
    ;;
*)
    echo "Unknown architecture: $ARCH"
    exit 1
    ;;
esac

# Make sure the target directory is writable.
if [ ! -w "$TARGET" ]; then
    echo "Target directory $TARGET is not writable."
    echo "Please run this script through 'sudo' to allow writing to $TARGET."
    echo
    echo "If you're running this script from a terminal, you can do so using"
    echo "  curl -fsSL https://raw.githubusercontent.com/asdf-vm/asdf/v${VERSION}/install.sh | sudo sh"
    exit 1
fi

# Make sure we don't overwrite an existing installation.
if [ -f "$TARGET/asdf" ]; then
    echo "Target path $TARGET/asdf already exists."
    echo "If you have an existing asdf installation, please first remove it using"
    echo "  sudo rm '$TARGET/asdf'"
    exit 1
fi

# Change into temporary directory.
tmpdir="$(mktemp -d)"
cd "$tmpdir"

# Download release archive.
download_link="https://github.com/asdf-vm/asdf/releases/download/v${VERSION}/${FILE}.tar.gz"
curl -L -s -O $download_link

# Unzip release archive.
tar -xf "${FILE}.tar.gz"
# Add asdf to path.
chmod +x ./asdf
cp ./asdf "$TARGET"
echo "Installed $("$TARGET/asdf" -v) at $TARGET/asdf."

# Clean up temporary directory.
cd "$OLDPWD"
rm -rf "$tmpdir" || true