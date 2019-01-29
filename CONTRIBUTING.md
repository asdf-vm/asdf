# How to Contribute to asdf

## Did you find a bug?

**Ensure the bug is actually an issue with asdf and not a plugin.** If the bug
only occurs when using one tool installed by asdf and not others it's likely an
issue with the asdf plugin. Find the plugin repository on
[asdf-vm/asdf-plugins](https://github.com/asdf-vm/asdf-plugins) and follow the
plugin creators instructions for reporting the bug.

**Ensure the bug was not already reported** by searching on GitHub under
[Issues](https://github.com/asdf-vm/asdf/issues).

If you are unable to find an open issue addressing the problem please [open
a new one](https://github.com/asdf-vm/asdf/issues/new). Please be as specific
as possible when reporting the issue. Include the observed behavior as well as
what you thought should have happened. Please also provide environmental
details like asdf version, shell, OS, etc...

## Did you write a patch that fixes a bug?

Open a new GitHub pull request with the patch. Refer to the [Development
section of the README](http://asdf-vm.github.io/asdf/#/contributing-core-asdf-vm) for the
details on how to run the unit tests. Please make sure that unit tests pass on
Travis CI.

## Did you create a plugin for asdf?

Please read the [creating plugins](docs/creating-plugins.md) guide.

## Do you want to contribute the asdf documentation?

Documentation can always be improved! Right now there is just the
[README](README.md) and the [creating plugins](docs/creating-plugins.md) guide.
The [wiki](https://github.com/asdf-vm/asdf/wiki) exists but is in a state of
disrepair. If you see something that can be improved please submit a pull
request or edit the wiki.

Thanks for contributing!
