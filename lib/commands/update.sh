update_command() {
  local update_to_head=$1

  (
  cd $(asdf_dir)
  pwd

  if [ "$update_to_head" = "--head" ]; then
    # Update to latest on the master branch
    git checkout master || exit 1

    # Pull down the latest changes on master
    git pull origin master || exit 1
    echo "Updated asdf to latest on the master branch"
  else
    # Update to latest release
    git fetch --tags || exit 1
    tags=$(git tag)

    # Pick the newest tag
    tag=$()

    # Update
    git checkout "$tag" || exit 1
    echo "Updated asdf to release $tag"
  fi
  )
}
