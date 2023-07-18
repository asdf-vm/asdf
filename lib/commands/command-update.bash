# -*- sh -*-

update_command() {
  local arg=$1

  (
    local asdf_dir=
    asdf_dir=$(asdf_dir)
    cd "$asdf_dir" || exit 1

    if [ -f asdf_updates_disabled ] || ! git rev-parse --is-inside-work-tree &>/dev/null; then
      printf "Update command disabled. Please use the package manager that you used to install asdf to upgrade asdf.\n"
      exit 42
    fi

    local ref=
    case $arg in
    --head)
      ref='--head'
      ;;
    --interactive | -i)
      source "$asdf_dir/lib/vendor/bash-term.bash"
      source "$asdf_dir/lib/utils-tty.bash"

      local -a tags=()
      readarray -d $'\n' -t tags <<<"$(print_tags | tac)"
      tty.array_select "${tags[0]}" tags
      local tag="$REPLY"

      ref=$tag
      ;;
    *)
      if [ -n "$1" ]; then
        ref="$1"

        if ! git rev-parse --verify "$ref"; then
          display_error "String '$ref' is not a valid git ref"
          exit 1
        fi
      else
        echo vvvv "$ref" >&3
        ref=$(print_tags --fetch | sed '$!d') || exit 1
      fi
      ;;
    esac

    do_update "$ref"
  )
}

do_update() {
  local ref=$1

  if [ "$ref" = "--head" ]; then
    # Update to latest on the master branch
    git fetch origin master
    git checkout master
    git reset --hard origin/master
    printf "Updated asdf to latest on the master branch\n"
  else
    # Update
    git checkout "$ref" || exit 1
    printf "Updated asdf to release or ref: %s\n" "$ref"
  fi
}

# stolen from https://github.com/rbenv/ruby-build/pull/631/files#diff-fdcfb8a18714b33b07529b7d02b54f1dR942
sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

print_tags() {
  local should_fetch=$1

  if [ "$should_fetch" = '--fetch' ]; then
    local default_branch='master'
    local remote=
    remote=$(git config "branch.$default_branch.remote") || exit 1
    git fetch "$remote" --tags || exit 1
  fi

  if [ "$(get_asdf_config_value "use_release_candidates")" = "yes" ]; then
    # Use the latest tag whether or not it is an RC
    git tag | sort_versions || exit 1
  else
    # Exclude RC tags when selecting latest tag
    git tag | sort_versions | grep -vi "rc" || exit 1
  fi
}

update_command "$@"
