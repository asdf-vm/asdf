#!/usr/bin/env bash

_asdf () {
  local cur
  cur=${COMP_WORDS[COMP_CWORD]}
  local cmd
  cmd=${COMP_WORDS[1]}
  local prev
  prev=${COMP_WORDS[COMP_CWORD-1]}
  local plugins
  plugins=$(asdf plugin-list | tr '\n' ' ')

  COMPREPLY=()

  case "$cmd" in
    plugin-update)
      COMPREPLY=($(compgen -W "$plugins --all" -- "$cur"))
      ;;
    plugin-remove|current|list|list-all)
      COMPREPLY=($(compgen -W "$plugins" -- "$cur"))
      ;;
    install)
      if [[ "$plugins" == *"$prev"* ]] ; then
        local versions
        versions=$(asdf list-all "$prev")
        COMPREPLY=($(compgen -W "$versions" -- "$cur"))
      else
        COMPREPLY=($(compgen -W "$plugins" -- "$cur"))
      fi
      ;;
    uninstall|where|reshim|local|global)
      if [[ "$plugins" == *"$prev"* ]] ; then
        local versions
        versions=$(asdf list "$prev")
        COMPREPLY=($(compgen -W "$versions" -- "$cur"))
      else
        COMPREPLY=($(compgen -W "$plugins" -- "$cur"))
      fi
      ;;
    *)
      local cmds='plugin-add plugin-list plugin-remove plugin-update install uninstall update current where which list list-all local global reshim'
      COMPREPLY=($(compgen -W "$cmds" -- "$cur"))
      ;;
  esac

  return 0
}

complete -F _asdf asdf
