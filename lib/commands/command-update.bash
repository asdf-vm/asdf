# -*- sh -*-

update_command() {
  local update_to_head=$1

  (
    cd "$(asdf_dir)" || exit 1

    if [ -f asdf_updates_disabled ] || ! git rev-parse --is-inside-work-tree &>/dev/null; then
      echo "Update command disabled. Please use the package manager that you used to install asdf to upgrade asdf."
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
    echo "Updated asdf to latest on the master branch"
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
    echo "Updated asdf to release $tag"
  fi
}

update_command "$@"
