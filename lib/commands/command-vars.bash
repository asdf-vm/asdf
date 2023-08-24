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

traverse_vars_files() {
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

find_vars_files() {
  if [ -e "${ASDF_DIR}/vars" ]; then
    printf '%s/vars\n' "${ASDF_DIR}"
  fi

  traverse_vars_files "$PWD"
}

# Reads file line-by-line and wraps multi-line values
#
#   FOO=bar
#   baz
#
# becomes
#
#   FOO='bar
#   baz'
#
multiline_vars() {
  [[ -n $ZSH_VERSION ]] && setopt LOCAL_OPTIONS KSH_ARRAYS BASH_REMATCH

  regex="^([A-Z_][0-9A-Za-z_]*)=(.*)"
  var=''
  value=''
  while read -r line; do
    if [[ "$line" =~ ${regex} ]]; then
      [[ -n $var ]] && printf "%s='%b'\n" $var "$value"
      var=${BASH_REMATCH[1]}
      value=$(sed -e "s/'/'\\\\''/g"i <<< ${BASH_REMATCH[2]})
    elif [[ -n $line ]]; then
      value="$value\n$(sed -e "s/'/'\\\\''/g"i <<< $line)"
    fi
  done
  [[ -n $var ]] && printf "%s='%b'\n" $var "$value"
}

sanitize_vars() {
  sed \
    -e "s/\(\\\\\\\$\)/'\\1'/g" \
    -e "s/\\\\\\\\/\\\\/g" \
    -e "s/\(\\\$[0-9A-Za-z_][0-9A-Za-z_]*\)/'\\1'/g" \
    -e "s/\(\\\${[0-9A-Za-z_][0-9A-Za-z_]*}\)/'\\1'/g" \
    -e "s/^[ "$'\t'"]*\([A-Za-z_][0-9A-Za-z_]*?\{0,1\}\)=/export \\1=/" \
    -e "s/export \([A-Za-z_][0-9A-Za-z_]*\)?=/[ -n \"\$\\1\" ] || export \\1=/g"
}

local files=$(find_vars_files)
while read -r file; do
  printf '# %s\n' "$file"
  {
    cat "$file"
    printf "\n"
  } | multiline_vars | sanitize_vars
  printf "\n"
done <<<"$files"
