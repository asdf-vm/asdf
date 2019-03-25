# Release README

If you are a user you can ignore everything in this directory. This directory
contains documentation and scripts for preparing and tagging new versions of
asdf and is only used by asdf maintainers.

## Tagging Release Candidates

To tag release candidates
1. Update the CHANGELOG. Make sure it contains an entry for the version you are
tagging as well as a dev version things that come after the tag (e.g. a heading
with the format `<next-version>-dev`).
2. Run the tests and the linter - `bats test` and `lint.sh`.
3. Run the release script. The new version must be in the format `0.0.0-rc0`.
For example: `release/tag.sh 0.0.0-rc0`.
4. If the release script succeeds, push to Github. Make sure to use the correct
remote to push to the official repository

## Tagging Releases

1. Update the CHANGELOG. Make sure it contains an entry for the version you are
tagging as well as a dev version things that come after the tag (e.g. a heading
with the format `<next-version>-dev`).
2. Run the tests and the linter - `bats test` and `lint.sh`.
3. Run the release script. The new version must be in the format `0.0.0`. For
example: `release/tag.sh 0.0.0`.
4. If the release script succeeds, push to Github. Make sure to use the correct
remote to push to the official repository
