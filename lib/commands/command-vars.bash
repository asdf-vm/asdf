# -*- sh -*-
#
# Usage: asdf vars
#
# Prints all asdf-vars environment variables applicable to the
# current working directory in the order they will be set. The output
# format is a script that may be passed to `eval` in a Bourne-
# compatible shell.
#
# For more information on asdf-vars, see:
# https://github.com/excid3/asdf-vars#readme

set -e

if [ "$1" = "--version" ] || [ "$1" = "-v" ]; then
  echo "asdf-vars 1.0.0"
  exit
fi

traverse-vars-files() {
  local root="$1"
  local results=""

  while [ -n "$root" ]; do
    if [ -e "${root}/.asdf-vars" ]; then
      results="${root}/.asdf-vars"$'\n'"$results"
    fi
    root="${root%/*}"
  done

  if [ -n "$results" ]; then
    echo -n "$results"
  else
    return 1
  fi
}

find-vars-files() {
  if [ -e "${ASDF_DIR}/vars" ]; then
    echo "${ASDF_DIR}/vars"
  fi

  traverse-vars-files "$PWD"
}

sanitize-vars() {
  sed \
    -e "/^[ "$'\t'"]*[A-Za-z_][0-9A-Za-z_]*?\{0,1\}=/ !d" \
    -e "s/'/'\\\\''/g" \
    -e "s/\(\\\\\\\$\)/'\\1'/g" \
    -e "s/\\\\\\\\/\\\\/g" \
    -e "s/\(\\\$[0-9A-Za-z_][0-9A-Za-z_]*\)/'\\1'/g" \
    -e "s/\(\\\${[0-9A-Za-z_][0-9A-Za-z_]*}\)/'\\1'/g" \
    -e "s/^[ "$'\t'"]*\([A-Za-z_][0-9A-Za-z_]*?\{0,1\}\)=\(.*\)$/export \\1='\\2'/" \
    -e "s/export \([A-Za-z_][0-9A-Za-z_]*\)?=/[ -n \"\$\\1\" ] || export \\1=/g"
}

while read -r file; do
  echo "# $file"
  {
    cat "$file"
    echo
  } | sanitize-vars
  echo
done < <(find-vars-files)
