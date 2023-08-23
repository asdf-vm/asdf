# -*- sh -*-
#
# Usage: asdf vars
#
# Prints all asdf-vars environment variables applicable to the
# current working directory in the order they will be set. The output
# format is a script that may be passed to `ev'al'` in a Bourne-
# compatible shell.
#
# For more information on asdf-vars, see:
# https://github.com/excid3/asdf-vars#readme

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
    printf '%s' "$results"
  else
    return 1
  fi
}

find-vars-files() {
  if [ -e "${ASDF_DIR}/vars" ]; then
    printf '%s/vars\n' "${ASDF_DIR}"
  fi

  traverse-vars-files "$PWD"
}

# Reads file line-by-line and concatenates multi-line values
#
#   FOO=bar
#   baz
#
# becomes
#
#   FOO='bar
#   baz'
#
multiline-vars() {
  regex='^([A-Z]\w*)=(.*)'
  var=''
  value=''
  while read -r line; do
    if [[ $line =~ $regex ]]; then
      [[ -n $var ]] && echo -e "$var='$value'"
      var=${BASH_REMATCH[1]}
      value=$(sed -e "s/'/'\\\\''/g"i <<< ${BASH_REMATCH[2]})
    elif [ ! $line == "\n" ]; then
      value="$value\n$line"
    fi
  done
  [[ -n $var ]] && echo -e "$var='$value'"
}

sanitize-vars() {
  sed \
    -e "s/\(\\\\\\\$\)/'\\1'/g" \
    -e "s/\\\\\\\\/\\\\/g" \
    -e "s/\(\\\$[0-9A-Za-z_][0-9A-Za-z_]*\)/'\\1'/g" \
    -e "s/\(\\\${[0-9A-Za-z_][0-9A-Za-z_]*}\)/'\\1'/g" \
    -e "s/^[ "$'\t'"]*\([A-Za-z_][0-9A-Za-z_]*?\{0,1\}\)=/export \\1=/" \
    -e "s/export \([A-Za-z_][0-9A-Za-z_]*\)?=/[ -n \"\$\\1\" ] || export \\1=/g"
}

while read -r file; do
  printf '# %s\n' "$file"
  {
    cat "$file"
    printf "\n"
  } | multiline-vars | sanitize-vars
  printf "\n"
done < <(find-vars-files)
