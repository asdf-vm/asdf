# ADR 001: Use marker file to signal incomplete installs

## Status

Accepted

## Context

Due to the initial implementation of asdf all plugin versions must be installed into a subdirectory inside the asdf installs directory. When an installation is terminated by `SIGTERM`, `SIGKILL`, a dropped network connection, or loss of power, the installation directory persists, even though the installation itself was interrupted and is likely in an incomplete or broken state. When a user later runs commands that check for installed versions asdf incorrectly treats these incomplete installations as installed. This happens because asdf considers every directory inside of `$ASDF_DATA_DIR/installs` as a valid installation. This leads to confusing behavior and errors the user may be unable to trace back to the root cause.

## Decision

We will implement a mechanism to mark incomplete version installation directories using a marker file stored in a dedicated directory. The mechanism will be robust and prevent any type of failure from resulting in an installation that asdf treats as valid when it is incomplete.

Here is how the install process will work:

1. Before beginning an installation asdf will check if the installation directory already exists along with a marker file in the install-locks directory with the same name. If it does, both the installation directory and marker are removed to clean up any stale incomplete installations.
2. asdf creates a marker file in the install-locks directory first (e.g., `$ASDF_DATA_DIR/install-locks/<tool>/<version>`), then creates the installation directory itself (e.g., `$ASDF_DATA_DIR/installs/<tool>/<version>`). Using a separate top-level directory ensures that:
   - Plugins which completely replace `$ASDF_INSTALL_PATH` contents do not inadvertently remove the marker
   - The install-locks directory is completely separate from the installs directory
3. The plugin's download and install callbacks are invoked, along with any pre-download and pre-install hooks. If the install callback fails the installation directory is removed.
4. When the installation is finished asdf removes the marker file.

Additionally, signal handlers will be registered for `SIGINT` and `SIGTERM` before installation that will trigger removal of the install directory.

Commands that list installed versions or check for an installed version do this by reading directories. Now there will be an additional check for the marker file in the install-locks directory for each version directory.

## Consequences

### Positive

* Signal interruption (Ctrl+C) properly cleans up partial installations
* No manual cleanup required for failed installations
* Clear distinction between complete and incomplete installations
* Users no longer encounter confusing errors from partial installations
* Backward compatibility is maintained, all plugins will continue to work
* Marker files survive plugins that replace `$ASDF_INSTALL_PATH` contents (e.g., asdf-nim)
* Simple implementation without temporary directory staging

### Negative/Neutral

* `install-locks` directory will be created at the top level of `$ASDF_DATA_DIR`
* Requires creating install-locks directory structure on first incomplete marker creation

## Related Issues

* https://github.com/asdf-vm/asdf/issues/2184
* https://github.com/asdf-vm/asdf/issues/2036
