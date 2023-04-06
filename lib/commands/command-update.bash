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
    local sha_of_tag
    local tag

    # fetch tags from remote
    git fetch origin --tags || exit 1

    sha_of_tag=$(git rev-list --tags --max-count=1) || exit 1
    tag=$(git describe --tags "$sha_of_tag") || exit 1

    # Update
    git checkout "$tag" || exit 1
    printf "Updated asdf to release %s\n" "$tag"
  fi
}

update_command "$@"
