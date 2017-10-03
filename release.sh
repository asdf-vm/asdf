#!/usr/bin/env bash

# Unoffical Bash "strict mode"
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
#ORIGINAL_IFS=$IFS
IFS=$'\t\n' # Stricter IFS settings

# shellcheck disable=SC2006
usage() {
    cat <<EOF

Usage: release.sh [new version]

This script is only intended for use by asdf maintainers when releasing new
versions of asdf. Plugin developers and asdf users do not need this script.

This script updates the hardcoded versions in the source code and README and
then commits them on the current branch. It then tags that commit with the
specified version.

If you run this script in error, or with the wrong version, you can undo the
changes by finding the original state in the list of actions listed in the
reflog:

    git reflog

Then revert to the original state by running `git checkout` with the reference
previous to the release tagging changes:

    git checkout HEAD@{21}

Then checkout the original branch again:

    git checkout master

You are back to the original state!

EOF
}

error_exit() {
    usage
    exit 1
}

new_version="${1:-}"
new_tag_name="v$new_version"

# Make sure the user provides a version
if [[ -z "$new_version" ]]
then
    echo "ERROR: no new version specified"
    error_exit
fi

# Make sure version passed in is a plain semantic version to guard against
# leading 'v'.
if ! [[ "${new_version:0:1}" =~ ^[0-9]+$ ]]; then
    echo >&2 "ERROR: semantic version should not start with a letter"
    error_exit
fi

# Make sure the version the user provided hasn't already been tagged
if git tag | grep "$new_tag_name" > /dev/null; then
    echo >&2 "ERROR: git tag with that version already exists"
    exit 1
fi

echo "INFO: Checking that all changes are commited and pushed"
git pull

# Disallow unstaged changes in the working tree
if ! git diff-files --check --exit-code --ignore-submodules -- >&2; then
    echo >&2 "ERROR: You have unstaged changes."
    exit 1
fi

# Disallow uncommitted changes in the index
if ! git diff-index --cached --exit-code -r --ignore-submodules HEAD -- >&2; then
    echo >&2 "ERROR: Your index contains uncommitted changes."
    exit 1
fi

# Update version in README
sed -i.bak "s|^\(git clone.*--branch \).*$|\1$new_tag_name|" README.md

# Update version in the VERSION file
echo "$new_tag_name" > VERSION

echo "INFO: Committing and tagging new version"

# Commit the changed files before tagging the new release
git add README.md
git add VERSION
git commit -m "Update version to $new_version"

git tag -a "$new_tag_name" -m "Version ${new_version}"

echo "INFO: done."
echo "INFO: Now you can push this local branch to the GitHub repository."
