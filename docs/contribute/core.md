# asdf

`asdf` core contribution guide.

## Initial Setup

Fork `asdf` on GitHub and/or Git clone the default branch:

```shell:no-line-numbers
# clone your fork
git clone https://github.com/<GITHUB_USER>/asdf.git
# or clone asdf
git clone https://github.com/asdf-vm/asdf.git
```

The tools for core development are in this repo's `.tool-versions`. If you wish to manage with `asdf` itself, add the plugins:

```shell:no-line-numbers
asdf plugin add bats https://github.com/timgluz/asdf-bats.git
asdf plugin add shellcheck https://github.com/luizm/asdf-shellcheck.git
asdf plugin add shfmt https://github.com/luizm/asdf-shfmt.git
```

Install the versions to develop `asdf` with:

```shell:no-line-numbers
asdf install
```

It _may_ be useful to not use `asdf` to manage the tools during development on your local machine as you may need to break functionality which would then break your dev tooling. Here's the raw list of tools:

- [bats-core](https://github.com/bats-core/bats-core): Bash Automated Testing System, for unit testing Bash or POSIX compliant scripts.
- [shellcheck](https://github.com/koalaman/shellcheck): Static analysis tool for shell scripts.
- [shfmt](https://github.com/mvdan/sh): A shell parser, formatter, and interpreter with bash support; includes shfmt

## Development

If you want to try out your changes without making change to your installed `asdf`, you can set the `$ASDF_DIR` variable to the path where you cloned the repository, and temporarily prepend the `bin` and `shims` directory of the directory to your path.

It is best to format, lint and test your code locally before you commit or push to the remote. Use the following scripts/commands:

```shell:no-line-numbers
# Shellcheck
./scripts/shellcheck.bash

# Format
./scripts/shfmt.bash

# Test: all tests
bats test/
# Test: for specific command
bats test/list_commands.bash
```

::: tip

**Add tests!** - Tests are **required** for new features and speed up review of bug fixes. Please cover new code paths before you create a Pull Request. See [bats-core documentation](https://bats-core.readthedocs.io/en/stable/index.html)

:::

## Bats Testing

It is **strongly encouraged** to examine the existing test suite and the [bats-core documentation](https://bats-core.readthedocs.io/en/stable/index.html) before writing tests.

Bats debugging can be difficult at times. Using the TAP output with `-t` flag will enable you to print outputs with the special file descriptor `>&3` during test execution, simplifying debugging. As an example:

```shell
# test/some_tests.bats

printf "%s\n" "Will not be printed during bats test/some_tests.bats"
printf "%s\n" "Will be printed during bats -t test/some_tests.bats" >&3
```

This is further documented in bats-core [Printing to the Terminal](https://bats-core.readthedocs.io/en/stable/writing-tests.html#printing-to-the-terminal).

## Pull Requests, Releases & Conventional Commits

`asdf` is using an automated release tool called [Release Please](https://github.com/googleapis/release-please) to automatically bump the [SemVer](https://semver.org/) version and generate the [Changelog](https://github.com/asdf-vm/asdf/blob/master/CHANGELOG.md). This information is determined by reading the commit history since the last release.

[Conventional Commit messages](https://www.conventionalcommits.org/) define the format of the Pull Request Title which becomes the commit message format on the default branch. This is enforced with GitHub Action [`amannn/action-semantic-pull-request`](https://github.com/amannn/action-semantic-pull-request).

Conventional Commit follows this format:

```:no-line-numbers
<type>[optional scope][optional !]: <description>

<!-- examples -->
fix: some fix
feat: a new feature
docs: some documentation update
docs(website): some change for the website
feat!: feature with breaking change
```

The full list of `<types>` are: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.

- `!`: indicates a breaking change
- `fix`: will create a new SemVer `patch`
- `feat`: will create a new SemVer `minor`
- `<type>!`: will create a new SemVer `major`

The Pull Request Title must follow this format.

::: tip

Use Conventional Commit message format for your Pull Request Title.

:::

## Docker Images

The [asdf-alpine](https://github.com/vic/asdf-alpine) and [asdf-ubuntu](https://github.com/vic/asdf-ubuntu) projects are an ongoing effort to provide Dockerized images of some asdf tools. You can use these docker images as base for your development servers, or for running your production apps.
