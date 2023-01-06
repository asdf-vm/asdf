# shellcheck shell=bash

asdf.get_info() {
  unset -v REPLY_{OS,ARCH}
  REPLY_OS=
  REPLY_ARCH=

  local asdf_os=
  case $OSTYPE in
  solaris*) asdf_os='solaris' ;;
  darwin*) asdf_os='macOS' ;;
  linux*) asdf_os='linux' ;;
  bsd*) asdf_os='bsd' ;;
  msys*) asdf_os='windows' ;;
  cygwin*) asdf_os='cygwin' ;;
  *) asdf_os='unknown' ;;
  esac

  local result_uname=
  result_uname=$(uname -m)

  # machine
  local asdf_arch=
  case $result_uname in
  x86) asdf_arch='x86' ;;
  i?86) asdf_arch='x86' ;;
  ia64) asdf_arch='ia64' ;;
  amd64) asdf_arch='x86_64' ;;
  x86_64) asdf_arch='x86_64' ;;
  arm64) asdf_arch='arm64' ;;
  sparc64) asdf_arch='sparc64' ;;
  *) asdf_arch='unknown' ;;
  esac

  # shellcheck disable=SC2034
  REPLY_OS=$asdf_os
  # shellcheck disable=SC2034
  REPLY_ARCH=$asdf_arch
}

