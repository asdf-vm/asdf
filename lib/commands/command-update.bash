# -*- sh -*-

update_command() {
  local update_to_head=$1

  (
    cd "$(asdf_dir)" || exit 1

    if [ -f asdf_updates_disabled ] || ! git rev-parse --is-inside-work-tree &>/dev/null; then
      printf "Update command disabled. Please use the package manager that you used to install asdf to upgrade asdf.\n"
      exit 42
    else
      do_update "$update_to_head"
    fi
  )
}

do_update() {
  local update_to_head=$1

  if [ "$update_to_head" = "--head" ]; then
    # Update to latest on the master branch
    git fetch origin master
    git checkout master
    git reset --hard origin/master
    printf "Updated asdf to latest on the master branch\n"
  else
    # Update to latest release
    git fetch origin --tags || exit 1

    if [ "$(get_asdf_config_value "use_release_candidates")" = "yes" ]; then
      # Use the latest tag whether or not it is an RC
      tag=$(git tag | sort_versions | sed '$!d') || exit 1
    else
      # Exclude RC tags when selecting latest tag
      tag=$(git tag | sort_versions | grep -vi "rc" | sed '$!d') || exit 1
    fi

    # Update
    git checkout "$tag" || exit 1
    printf "Updated asdf to release %s\n" "$tag"
  fi
}

# stolen from https://github.com/rbenv/ruby-build/pull/631/files#diff-fdcfb8a18714b33b07529b7d02b54f1dR942
sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

update_command "$@"
