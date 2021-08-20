# Changelog

## 0.8.1

Features

* Support for latest version in shell, local, and global commands (#802, #801)
* Parallel updating of all plugins (#626, #530)
* Print documentation website and GitHub URLs in help command (#820)

Fixed Bugs

* Fix plugin-update --all when there are no plugins (#805, #803)
* Ban `echo` command from asdf codebase (#806, #781)
* Add basic tests for for plugin-update command (#807)
* Cleanup unused code in plugin update tests (#810)
* Fix resolution of relative symlinks (#815, #625)
* Fixes to GitHub workflow (#833)
* Update no plugin installed error message (#818)
* Remove process substitution that was problematic when POSIXLY_CORRECT is set (#851, #581)
* Fix warnings from find command (#853)
* Ban the `sort -V` command from the asdf codebase (#755, #867)
* Fix `plugin update --all` so that the default branch is used for each plugin (#800)
* Fix issues with awk command on some platforms used by plugin update command (#924, #899, #919)
* Add completion for the `system` version (#911)

Documentation

* Link to Homebrew common issues from documentation site (#795)
* Remove -vm suffix name in documentation (#798, #796)
* Fix file renames in release script (#809)
* Update supported versions in documentation (#825)
* Fix references to icongram files (#827)
* Fix broken links in CONTRIBUTING.md (#832, #852)
* Fix broken link in README.md (#835)
* Improve zsh completion directions for macOS,ZSH,Homebrew (#843)
* Add GitHub discussions link (#839)
* Add note about unsolicited formatting pull requests (#848)
* Fix formatting of GitHub name (#847)
* Explain the difference between ASDF_DIR and ASDF_DATA_DIR (#855)
* Update BATS link to bats-core GitHub repo (#858)
* Instruct users to symlink completions for Fish shell (#860)
* Support alternate locations for `.zshrc` (#871)
* Add "Add translation" link to navbar (#876)
* Clarify usage of the ASDF_DEFAULT_TOOL_VERSIONS_FILENAME variable (#912, #900)
* Show how to use the `system` version (#925, #868)
* Remove instructions for installing dependencies for Homebrew installs (#937, #936)

## 0.8.0

Features

* Add support for plugin documentation callback scripts (#512, #757)
* Add support for installing one tool specified in `.tool-versions` (#759, #760)
* Improve introduction and install sections of documentation (#699, #740)
* Add dependencies for openSUSE and ArchLinux to documentation (#714)
* Add support for keeping downloaded tool source code (#74, #669)
* Add `asdf info` command to print debug information (#786, #787)

Fixed Bugs

* Fix typo that caused plugin-test to erroneously fail (#780)
* Make sure shims are only appended to `PATH` once in Fish shell (#767, #777, #778)
* Print `.tool-versions` file path on shim error (#749, #750)
* Add `column` and `sort -V` to list of banned commands for the asdf codebase (#661, #754)
* Use editorconfig for shell formatting (#751)
* Remove use of `column` command in favor of awk (#721)
* Add `asdf shell` command to help output (#715, #737)
* Ensure consistency in indentation for message shown when no versions installed (#728)
* Fix dead link in documentation (#733)
* Fix typo in docs/core-manage-versions.md (#722)
* Fix a typo in the `asdf env` command documentation (#717)
* Fix Fish shell documentation (#709)
* Only list asdf dependencies on asdf website (#511, #710)
* Add CODEOWNERS file for GitHub reviews (#705)
* Add unit test for `asdf plugin-add` exit code (#689)

## 0.7.8

Features

* Add support for `post-plugin-add` and `pre-plugin-remove` in plugins. Add configurable command hooks for plugin installation and removal (#670, #683)

    ```shell
    pre_asdf_plugin_remove = echo will remove plugin ${1}
    pre_asdf_plugin_remove_foo = echo will remove plugin foo
    post_asdf_plugin_remove = echo removed plugin ${1}
    post_asdf_plugin_remove_foo = echo removed plugin foo
    ```

* Use different exit code if updates are disabled (#676)

Fixed Bugs

* Make sure extension commands are properly displayed by `asdf help`

  Extension commands are now expected to be inside plugins's `lib/commands/command-*.bash` instead of `bin/command*`.

  This change was made for two reasons: Keep the convention that all files to be sourced by bash should end with
  the `.bash` extension. And the `lib/commands/` directoy mirrors the location of asdf own core commands.

  Added tests to make sure `asdf help` properly displays available extension commands.

* Remove automatic `compinit` from asdf.sh (#674, #678)

## 0.7.7

Features

* Add .bash file extension to files executed by Bash (#664)
* Add security policy (#660)

Fixed Bugs

* consistent use of plugin_name (#657)
* Default ZSH_VERSION to empty string (#656)
* Fix support for path version (#654)
* Fix hanging 'asdf update is a noop for non-git repos' test (#644)
* Fix Bash completions for `plugin-add` (#643)
* Fix `--unset` for Fish shell (#640)
* Misc. documentation fixes (#631, #652)
* Defaults to empty ASDF_DATA_DIR (#630)
* Remove shebang lines of sourced scripts (#629)
* Ignore shim directory for executable lookups (#623)
* Fix issue with preset version warning assuming that the shim name and plugin name are the same (#622)

## 0.7.6

Features

* Improve output format of `asdf plugin list all`

  Long plugin names were causing problems with how we used printf.
  Now we use the `column` command to properly render output.

* Now `asdf plugin list` can take both `--urls` and `--refs` options.

  When `--url` is used, we print the plugin's remote origin URL.
  While `--refs` prints the git branch/commit the plugin is at.

* It's now possible to update a plugin to an specific branch/commit.

  `asdf plugin update <name> [git-ref]`

  Checkouts a plugin to the specified `git-ref`. Defaults to `master`

* Now the `asdf plugin test` command can be specified with a plugin commit/branch to test.

  This will help CI checks to actually test the commit they are running for.
  Previously we always used the plugin's `master` branch.

* Subcommand CLI support.

   Users familiar with sub-command aware tools like `git` can now
   use `asdf` commands in the same way. For example:

   `asdf plugin list all` is equivalent to `asdf plugin-list-all`

   This is also the case for plugin extension commands, where the
   plugin name is an asdf main subcommand. ie. Having a `foo` plugin
   you can invoke: `asdf foo bar`

* Make `asdf plugin test` use the new `asdf latest` command. (#541)

   If a plugin version is not given explicitly, we use `asdf latest` to
   obtain the version of plugin to install for testing.

* `asdf --version` displays git revision when asdf_dir is a git clone.

   This will allow better bug reports since people can now include the
   git commit they are using.

* Add support for asdf extension commands.

   Plugins can provide `bin/command*` scripts or executables that will
   be callable using the asdf command line interface.

   See `docs/plugins-create.md` for more info.

* Add support for installing the latest stable version of a tool (#216)

    ```shell
    asdf install python latest
    asdf install python latest:3.7 # installs latest Python 3.7 version
    ```

* Add `asdf latest` command to display the latest stable version of a tool (#575)

    ```shell
    asdf latest python
    asdf latest python 3.7 # displays latest Python 3.7 version
    ```

* Add support for filtering versions returned by `asdf list-all`

    ```shell
    asdf list-all python 3.7 # lists available Python 3.7 versions
    ````

## 0.7.5

Features

* Add AppVeyor config for builds on Windows, for eventual Windows support (#450, #451)
* Add `--unset` flag to shell command (#563)

Fixed Bugs

* Fix multiple version install (#540, #585)
* Handle dashes in executable/shim names properly (#565, #589)
* Fix bug in sed command so `path:...` versions are handled correctly (#559, #591)

## 0.7.4

Features

* Add quite flag to git clone (#546)
* Improve docs for Homebrew (#553, #554)

Fixed Bugs

* Don't include the current directory in `PATH` variable in `asdf env` environment (#543, #560)
* Fix `asdf plugin-test` dependency on Git when installed via Homebrew (#509, #556)

## 0.7.3

Features

* Make `asdf install` check for versions in legacy files (#533, #539)

Fixed Bugs

* Address shellcheck warning and use shell globbing instead of `ls` (#525)

## 0.7.2

Features

* Add unit tests for untested code in asdf.sh and asdf.fish (#286, #507, #508)
* Switched to a maintained version of BATS (#521)

Fixed Bugs

* Don't iterate on output of `ls` (#513)
* Check shims for full tool version so adding new versions to a shim works properly (#517, #524)

## 0.7.1

Features

* Add mksh support
* Add documentation about using multiple versions of the same plugin
* Remove post_COMMAND hooks
* Add `asdf shell` command to set a version for the current shell (#480)
* Ignore comments in .tool-versions (#498, #504)

Fixed Bugs

* Avoid modifying `fish_user_paths`
* Restore support for legacy file version (#484)
* Restore support for multiple versions
* Fix bug when trying to locate shim (#488)
* Run executable using `exec` (#502)

## 0.7.0

Features

* Shims can be invoked directly via `asdf exec <command> [args...]` without requiring to have all shims on path (#374).
* New `asdf env <command>` can be used to print or execute with the env that would be used to execute a shim. (#435)
* Configurable command hooks from `.asdfrc` (#432, #434)
  Suppose a `foo` plugin is installed and provides a `bar` executable,
  The following hooks will be executed when set:

    ```shell
    pre_asdf_install_foo = echo will install foo version ${1}
    post_asdf_install_foo = echo installed foo version ${1}

    pre_asdf_reshim_foo = echo will reshim foo version ${1}
    post_asdf_reshim_foo = echo reshimmed foo version ${1}

    pre_foo_bar = echo about to execute command bar from foo with args: ${@}
    post_foo_bar = echo just executed command bar from foo with args: ${@}

    pre_asdf_uninstall_foo = echo will remove foo version ${1}
    post_asdf_uninstall_foo = echo removed foo version ${1}
    ```
* New shim version meta-data allows shims to not depend on a particular plugin
  nor on its relative executable path (#431)
  Upgrading requires shim re-generation and should happen automatically by `asdf-exec`:
  `rm -rf ~/.asdf/shims/` followed by `asdf reshim`
* Added lots of tests for shim execution.
  We now make sure that shim execution obeys plugins hooks like `list-bin-paths` and
  `exec-path`.
* Shims now are thin wrappers around `asdf exec` that might be faster
  for most common use case: (versions on local .tool-versions file) but fallbacks to
  slower `get_preset_version_for` which takes legacy formats into account.
* Shim exec recommends which plugins or versions to set when command is not found.
* `asdf reshim` without arguments now reshims all installed plugins (#407)
* Add `asdf shim-versions <executable>` to list on which plugins and versions is a command
  available. (#380, #433)
* Add documentation on installing dependencies via Spack (#471)

Fixed Bugs

* Fix `update` command so it doesn't crash when used on Brew installations (#429, #474, #439, #436)

## 0.6.3

Features

* Make `which` command work with any binary included in a plugin installation (#205, #382)
* Add documentation for documentation website (#274, #396, #422, #423, #427, #430)

Fixed Bugs

* Silence errors during tab completion (#404)
* Remove unused asdf shims directory from `PATH` (#408)
* Fix issues with update command that prevented updates for installations in custom locations (#411)
* Fix shellcheck warnings on OSX (#416)
* Add tests for versions set by environment variables (#417, #327)
* Continue `list` output even when version is not found (#419)
* Fixed user paths for fish (#420, #421)
* Custom exec path tests (#324, #424)

## 0.6.2

Fixed Bugs

* Fix `system` logic so shims directory is removed from `PATH` properly (#402, #406)
* Support `.tool-versions` files that don't end in a newline (#403)

## 0.6.1

Features

* Make `where` command default to current version (#389)
* Optimize code for listing all plugins (#388)
* Document `$TRAVIS_BUILD_DIR` in the plugin guide (#386)
* Add `--asdf-tool-version` flag to plugin-test command (#381)
* Add `-p` flag to `local` command (#377)

Fixed Bugs

* Fix behavior of `current` command when multiple versions are set (#401)
* Fix fish shell init code (#392)
* Fix `plugin-test` command (#379)
* Add space before parenthesis in `current` command output (#371)

## 0.6.0

Features

* Add support for `ASDF_DATA_DIR` environment variable (#275, #335, #361, #364, #365)

Fixed Bugs

* Fix `asdf current` so it works when no versions are installed (#368, #353)
* Don't try to install system version (#369, #351)
* Make `resolve_symlink` function work with relative symlinks (#370, #366)
* Fix version changing code so it preserves symlinks (#329, #337)
* Fix ShellCheck warnings (#336)

## 0.5.1

Features

* Better formatting for `asdf list` output (#330, #331)

Fixed Bugs

* Correct environment variable name used for version lookup (#319, #326 #328)
* Remove unnecessary `cd` in `asdf.sh` (#333, #334)
* Correct Fish shell load script (#340)

## 0.5.0

Features

* Changed exit codes for shims so we use codes with special meanings when possible (#305, #310)
* Include plugin name in error message if plugin doesn't exist (#315)
* Add support for custom executable paths (#314)
* `asdf list` with no arguments should list all installed versions of all plugins (#311)

Fixed Bugs

* Print "No version set" message to stderr (#309)
* Fix check for asdf directories in path for Fish shell (#306)

## 0.4.3

Features

* Suggest action when no version is set (#291, #293)

Fixed Bugs

* Fix issue with asdf not always being added to beginning of `$PATH` (#288, #303, #304)
* Fix incorrect `ASDF_CONFIG_FILE` environment variable name (#300)
* Fix `asdf current` so it shows environment variables that are setting versions (#292, 294)

## 0.4.2

Features

* Add support for `ASDF_DEFAULT_TOOL_VERSIONS_FILENAME` environment variable (#201, #228)
* Only add asdf to `PATH` once (#261, #271)
* Add `--urls` flag to `plugin-list` commands (#273)

Fixed Bugs

* Incorrect `grep` command caused version command to look at the wrong tool when reporting the version (#262)

## 0.4.1

Features

* `asdf install` will also search for `.tool-versions` in parent directories (#237)

Fixed Bugs

* bad use of `sed` caused shims and `.tool-versions` to be duplicated with `-e` (#242, #250)
* `asdf list` now outputs ref-versions as used on `.tool-versions` file (#243)
* `asdf update` will explicitly use the `origin` remote when updating tags (#231)
* All code is now linted by shellcheck (#223)
* Add test to fail builds if banned commands are found (#251)

## 0.4.0

Features

* Add CONTRIBUTING guidelines and GitHub issue and pull request templates (#217)
* Add `plugin-list-all` command to list plugins from asdf-plugins repo. (#221)
* `asdf current` shows all current tool versions when given no args (#219)
* Add asdf-plugin-version metadata to shims (#212)
* Add release.sh script to automate release of new versions (#220)

Fixed Bugs

* Allow spaces on path containing the `.tool-versions` file (#224)
* Fixed bug in `--version` functionality so it works regardless of how asdf was installed (#198)

## 0.3.0

Features

* Add `update` command to make it easier to update asdf to the latest release (#172, #180)
* Add support for `system` version to allow passthrough to system installed tools (#55, #182)

Fixed Bugs

* Set `GREP_OPTIONS` and `GREP_COLORS` variables in util.sh so grep is always invoked with the correct settings (#170)
* Export `ASDF_DIR` variable so the Zsh plugin can locate asdf if it's in a custom location (#156)
* Don't add execute permission to files in a plugin's bin directory when adding the plugin (#124, #138, #154)

## 0.2.1

Features

* Determine global tool version even when used outside of home directory (#106)

Fixed Bugs

* Correct reading of `ref:` and `path:` versions (#112)
* Remove shims when uninstalling a version or removing a plugin (#122, #123, #125, #128, #131)
* Add a helpful error message to the install command (#135)

## 0.2.0

Features

* Improve plugin API for legacy file support (#87)
* Unify `asdf local` and `asdf global` version getters as `asdf current` (#83)
* Rename `asdf which` to `asdf current` (#78)

Fixed Bugs

* Fix bug that caused the `local` command to crash when the directory contains whitespace (#90)
* Misc typo corrections (#93, #99)

## 0.1.0

* First tagged release
