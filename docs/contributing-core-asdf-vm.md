## Development

To develop the project, simply `git clone` the master branch.

If you want to try out your changes without making change to your installed `asdf`, you can set the `$ASDF_DIR` variable to the path where you cloned the repository, and temporarily prepend the `bin` and `shims` directory of the directory to your path.

Tools we use:

- [bats](https://github.com/sstephenson/bats) for testing. Make sure
  `bats test/` passes after you made your changes.
- [Shellcheck](https://github.com/koalaman/shellcheck) for static analysis of our shell scripts.

## Docker Images

The [asdf-alpine][asdf-alpine] and [asdf-ubuntu][asdf-ubuntu] projects are an
ongoing effort to provide Dockerized images of some asdf tools. You can use
these docker images as base for your development servers, or for running your
production apps.

[asdf-alpine]: https://github.com/vic/asdf-alpine
[asdf-ubuntu]: https://github.com/vic/asdf-ubuntu
