#compdef asdf
#description tool to manage versions of multiple runtimes

local curcontext="$curcontext" state state_descr line subcmd
local asdf_dir="${ASDF_DATA_DIR:-$HOME/.asdf}"

local -a asdf_plugin_commands
asdf_plugin_commands=(
  'add:add plugin from asdf-plugins repo or from git URL'
  'list:list installed plugins (--urls with URLs)'
  'remove:remove named plugin and all packages for it'
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
  'set:Set a tool version in a .tool-version file'
  'list:list installed versions of a tool'

  # utils
  'exec:executes the command shim for the current version'
  'env:prints or runs an executable under a command environment'
  'info:print os, shell and asdf debug information'
  'version:print the currently installed version of ASDF'
  'reshim:recreate shims for version of a tool'
  'shim:shim management sub-commands'
  'shimversions:list for given command which plugins and versions provide it'
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

# Get available git refs for a plugin
_asdf__plugin_git_refs() {
  local plugin=$1
  local data_dir=${ASDF_DATA_DIR:-$HOME/.asdf}
  local plugin_path="$data_dir/plugins/$plugin"

  if [[ -d "$plugin_path/.git" ]]; then
    # Branches
    git -C "$plugin_path" branch -r 2> /dev/null | \
      sed \
        -e 's/^[[:space:]]*[^\/]*\///' \
        -e 's/[[:space:]]*->.*$//' \
        -e 's/\(.*\)/\1:Remote branch \1/' | \
      sort -fd
    # Tags
    git -C "$plugin_path" tag 2> /dev/null | \
      sed -e 's/\(.*\)/\1:Tag \1/' | \
      sort -V
    # Recent commits
    git -C "$plugin_path" log --pretty=format:'%h:%s' -n 10 2> /dev/null
  fi
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
  (plugin)
    if (( CURRENT == 3 )); then
      _describe -t asdf-plugin-commands 'ASDF Plugin Commands' asdf_plugin_commands
    else
      local plugin_subcmd="${words[3]}"
      case "$plugin_subcmd" in
      (add)
        if (( CURRENT == 4 )); then
          _asdf__available_plugins
        elif (( CURRENT == 5 )); then
            _arguments "*:${words[4]} plugin url:_urls"
        fi
        return
        ;;
      (update)
        if (( CURRENT == 4 )); then
          _alternative \
            'all:all:(--all)' \
            'asdf-available-plugins:Installed ASDF Plugins:_asdf__installed_plugins'
        elif (( CURRENT == 5 )); then
          if [[ ${words[4]} != "--all" ]]; then
            local -a refs
            while IFS=: read -r value descr; do
              refs+=( "${value}:${descr}" )
            done < <(_asdf__plugin_git_refs ${words[4]})
            _describe -V -t git-refs 'Git References' refs
          fi
        fi
        ;;
      (remove)
        _asdf__installed_plugins
        return
        ;;
      (list)
        case $CURRENT in
          4)
            _alternative \
              'flags:flags:(--urls --refs)' \
              'commands:commands:(all)'
            return
            ;;
          5)
            if [[ ${words[4]} == --* ]]; then
              local used_flags=("${words[@]}")
              local -a available_flags
              available_flags=()
              if [[ ! "${used_flags[@]}" =~ "--urls" ]]; then
                available_flags+=("--urls")
              fi
              if [[ ! "${used_flags[@]}" =~ "--refs" ]]; then
                available_flags+=("--refs")
              fi
              (( ${#available_flags[@]} )) && compadd -- "${available_flags[@]}"
            fi
            return
            ;;
        esac
        ;;
      esac
    fi
    ;;
  (current)
    _asdf__installed_plugins
    ;;
  (list)
    case $CURRENT in
      3)
        _alternative \
          'command:command:(all)' \
          'plugin:plugin:_asdf__installed_plugins'
        ;;
      4)
        if [[ ${words[3]} == "all" ]]; then
          _asdf__installed_plugins
        else
          # For normal list: show installed versions with optional filter
          _asdf__installed_versions_of ${words[3]}
        fi
        ;;
      5)
        if [[ ${words[3]} == "all" ]]; then
          local versions
          if versions=$(asdf list all "${words[4]}" 2>/dev/null); then
            _wanted "remote-versions-${words[4]}" \
              expl "Available versions of ${words[4]}" \
              compadd -- ${(f)versions}
          else
            _message "Unable to fetch versions for ${words[4]}"
          fi
        fi
        ;;
    esac
    ;;
  (install)
    if (( CURRENT == 3 )); then
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
    fi
    ;;
  (uninstall|reshim)
    _arguments '1:plugin-name: _asdf__installed_plugins' '2:tool-version:{_asdf__installed_versions_of ${words[3]}}'
    ;;
  (set)
    case $CURRENT in
      3)
        _alternative \
          'flags:flags:(-u -p)' \
          'plugin:plugin:_asdf__installed_plugins'
        ;;
      4)
        if [[ ${words[3]} == -* ]]; then
          # After flag comes plugin name
          _asdf__installed_plugins
        else
          # Versions for the plugin
          local versions
          if versions=$(asdf list all "${words[3]}" 2>/dev/null); then
            _wanted "versions-${words[3]}" \
              expl "Available versions of ${words[3]}" \
              compadd -- ${(f)versions}
          fi
        fi
        ;;
      *)
        # Additional versions for multiple version support
        if [[ ${words[3]} == -* ]]; then
          local plugin="${words[4]}"
        else
          local plugin="${words[3]}"
        fi
        local versions
        if versions=$(asdf list all "$plugin" 2>/dev/null); then
          _wanted "versions-$plugin" \
            expl "Available versions of $plugin" \
            compadd -- ${(f)versions}
        fi
        ;;
    esac
    ;;
  (where)
    # version is optional
    _arguments '1:plugin-name:_asdf__installed_plugins' '2::tool-version:{_asdf__installed_versions_of ${words[3]}}'
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
