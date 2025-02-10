#compdef asdf
#description tool to manage versions of multiple runtimes

local curcontext="$curcontext" state state_descr line subcmd
local asdf_dir="${ASDF_DATA_DIR:-$HOME/.asdf}"

local -a asdf_plugin_commands
asdf_plugin_commands=(
  'add:add plugin from asdf-plugins repo or from git URL'
  'list:list installed plugins (--urls with URLs)'
  'list all:list all plugins registered in asdf-plugins repo'
  'remove:remove named plugin and all versions for it'
  'update:update named plugin (or --all)'
)
local -a asdf_commands
asdf_commands=( # 'asdf help' lists commands with help text
  # plugins
  'plugin:plugin management sub-commands'

  # tools
  'install:install tool at stated version, or all from .tools-versions'
  'uninstall:remove a specific version of a tool'
  'current:display current versions for named tool (else all)'
  'latest:display latest version available to install for a named tool'
  'where:display install path for given tool at optional specified version'
  'which:display path to an executable'
  'set:set tool version'
  'list:list installed versions of a tool'
  'list all:list all available (remote) versions of a tool'

  # utils
  'exec:executes the command shim for the current version'
  'env:prints or runs an executable under a command environment'
  'info:print os, shell and asdf debug information'
  'version:print the currently installed version of ASDF'
  'reshim:recreate shims for version of a tool'
  'shim:shim management sub-commands'
  'shimversions:list for given command which plugins and versions provide it'
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

_asdf__installed_versions_of_plus_system() {
  local plugin_dir="${asdf_dir:?}/installs/${1:?need a plugin version}"
  if [[ ! -d "$plugin_dir" ]]; then
    _wanted "asdf-versions-$1" expl "ASDF Plugin ${(q-)1} versions" \
      compadd -x "no versions installed"
    return
  fi
  local -a versions
  versions=( "$plugin_dir"/*(:t) )
  versions+="system"
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
subcmd2="${words[3]}"

case "$subcmd" in
  (plugin)
    case "$subcmd2" in
      (add)
        if (( CURRENT == 4 )); then
          _asdf__available_plugins
        else
          if (( CURRENT == 5 )); then
            _arguments "*:${words[3]} plugin url:_urls"
          fi
        fi
        return
        ;;
      (update)
        _alternative \
          'all:all:(--all)' \
          'asdf-available-plugins:Installed ASDF Plugins:_asdf__installed_plugins'
                  return
                  ;;
      (remove)
        _asdf__installed_plugins
        return
        ;;
      (list)
        _asdf__installed_plugins
        return
        ;;
      (*)
        _describe -t asdf-commands 'ASDF Plugin Commands' asdf_plugin_commands
        return
        ;;
    esac
    ;;
  (current)
    _asdf__installed_plugins
    ;;
  (install)
    if (( CURRENT == 3)); then
      _asdf__installed_plugins
      return
    elif (( CURRENT == 4 )); then
      local tool="${words[3]}"
      local ver_prefix="${words[4]}"
      if [[ $ver_prefix == latest:* ]]; then
        _wanted "latest-versions-$tool" \
          expl "Latest version" \
          compadd -- latest:${^$(asdf list all "$tool")}
                else
                  _wanted "latest-tag-$tool" \
                    expl "Latest version" \
                    compadd -- 'latest' 'latest:'
                                      _wanted "remote-versions-$tool" \
                                        expl "Available versions of $tool" \
                                        compadd -- $(asdf list all "$tool")
      fi
      return
    fi
    ;;
  (latest)
    if (( CURRENT == 3 )); then
      _alternative  \
        'all:all:(--all)' \
        'asdf-available-plugins:Installed ASDF Plugins:_asdf__installed_plugins'
            elif (( CURRENT == 4)); then
              local tool="${words[3]}"
              local query=${words[4]}
              [[ -n $query ]] || query='[0-9]'
              _wanted "latest-pattern-$tool" \
                expl "Pattern to look for in matching versions of $tool" \
                compadd -- $(asdf list all "$tool" "$query")
    fi
    ;;
  (uninstall|reshim)
    compset -n 2
    _arguments '1:plugin-name: _asdf__installed_plugins' '2:tool-version:{_asdf__installed_versions_of ${words[2]}}'
    ;;
  (set)
    compset -n 2
    _arguments '1:plugin-name: _asdf__installed_plugins' '2:tool-version:{_asdf__installed_versions_of_plus_system ${words[2]}}'
    ;;
  (where)
    # version is optional
    compset -n 2
    _arguments '1:plugin-name: _asdf__installed_plugins' '2::tool-version:{_asdf__installed_versions_of ${words[2]}}'
    ;;
  (which|shimversions)
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
esac
