#compdef asdf
#description tool to manage versions of multiple runtimes

local curcontext="$curcontext" state state_descr line subcmd
local asdf_dir="${ASDF_DATA_DIR:-$HOME/.asdf}"

local -a asdf_commands
asdf_commands=( # 'asdf help' lists commands with help text
  'plugin-add:add plugin from asdf-plugins repo or from git URL'
  'plugin-list:list installed plugins (--url with URLs)'
  'plugin-list-all:list all plugins registered in asdf-plugins repo'
  'plugin-remove:remove named plugin and all packages for it'
  'plugin-update:update named plugin (or --all)'
  'install:install plugin at stated version, or all from .tools-versions'
  'uninstall:remove a specific version of a package'
  'current:display current versions for named package (else all)'
  'where:display install path for given package at optional specified version'
  'which:display path to an executable'
  'shell:via env vars, set package to version in current shell'
  'local:set package local version'
  'global:set package global version'
  'list:list installed versions of a package'
  'list-all:list all available (remote) versions of a package'
  'exec:executes the command shim for the current version'
  'env:prints or runs an executable under a command environment'
  'reshim:recreate shims for version of a package'
  'shim-versions:list for given command which plugins and versions provide it'
  'update:update ASDF to the latest stable release (unless --head)'
)

_asdf__available_plugins() {
  local plugin_dir="${asdf_dir:?}/repository/plugins"
  if [[ ! -d "$plugin_dir" ]]; then
    _wanted asdf-available-plugins expl 'ASDF Installable Plugins' \
      compadd -x "no plugins repository found"
    return
  fi
  local -a plugins
  plugins=( "$plugin_dir"/*(:t) )
  _wanted asdf-available-plugins expl 'ASDF Installable Plugins' \
    compadd -a plugins
}

_asdf__installed_plugins() {
  local plugin_dir="${asdf_dir:?}/plugins"
  if [[ ! -d "$plugin_dir" ]]; then
    _wanted asdf-plugins expl 'ASDF Plugins' \
      compadd -x "no plugins dir, none installed yet"
    return
  fi
  local -a plugins
  plugins=( "$plugin_dir"/*(:t) )
  _wanted asdf-plugins expl 'ASDF Plugins' \
    compadd -a plugins
}

_asdf__installed_versions_of() {
  local plugin_dir="${asdf_dir:?}/installs/${1:?need a plugin version}"
  if [[ ! -d "$plugin_dir" ]]; then
    _wanted "asdf-versions-$1" expl "ASDF Plugin ${(q-)1} versions" \
      compadd -x "no versions installed"
    return
  fi
  local -a versions
  versions=( "$plugin_dir"/*(:t) )
  _wanted "asdf-versions-$1" expl "ASDF Plugin ${(q-)1} versions" \
    compadd -a versions
}

if (( CURRENT == 2 )); then
  _arguments -C : '--version[version]' ':command:->command'
fi

case "$state" in
(command)
  _describe -t asdf-commands 'ASDF Commands' asdf_commands
  return
  ;;
esac
subcmd="${words[2]}"
curcontext="${curcontext%:*}=$subcmd:"

case "$subcmd" in
(plugin-add)
  if (( CURRENT == 3 )); then
    _asdf__available_plugins
  else
    # Optional URL
    curcontext="${curcontext/=plugin-add:/=plugin-add-${words[3]}:}"
    if (( CURRENT == 4 )); then
      _arguments "*:${words[3]} package url:_urls"
    fi
  fi
  ;;
(plugin-remove|current|list|list-all)
  (( CURRENT == 3 )) && _asdf__installed_plugins
  ;;
(plugin-update)
  (( CURRENT == 3 )) && _alternative \
    'all:all:(--all)' \
    'asdf-available-plugins:Installed ASDF Plugins:_asdf__installed_plugins'
  ;;
(install)
  if (( CURRENT == 3 )); then
    _asdf__installed_plugins
  elif (( CURRENT == 4 )); then
    _wanted "remote-versions-${words[3]}" \
      expl "Available versions of ${words[3]}" \
      compadd -- $(asdf list-all "${words[3]}")
  fi
  ;;
(uninstall|where|shell|local|global)
  if (( CURRENT == 3 )); then
    _asdf__installed_plugins
  elif (( CURRENT == 4 )); then
    _asdf__installed_versions_of "${words[3]}"
  fi
  ;;
(which|shim-versions)
  _wanted asdf-shims expl "ASDF Shims" compadd -- "${asdf_dir:?}/shims"/*(:t)
  ;;
(exec)
  # asdf exec <shim-cmd> [<shim-cmd args ...>]
  if (( CURRENT == 3 )); then
    _wanted asdf-shims expl "ASDF Shims" compadd -- "${asdf_dir:?}/shims"/*(:t)
  else
    compset -n 3
    _normal -p "asdf-shims-${words[3]}"
  fi
  ;;
(env)
  # asdf exec <shim-name> <arbitrary-cmd> [<cmd args ...>]
  if (( CURRENT == 3 )); then
    _wanted asdf-shims expl "ASDF Shims" compadd -- "${asdf_dir:?}/shims"/*(:t)
  else
    compset -n 4
    _normal -p "asdf-shims-${words[3]}"
  fi
  ;;
(update)
  (( CURRENT == 3 )) && compadd -- --head
  ;;
esac
