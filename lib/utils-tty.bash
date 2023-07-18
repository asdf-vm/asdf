# shellcheck shell=bash

tty.fullscreen_init() {
  stty -echo
  term.cursor_hide -p
  term.cursor_savepos -p
  term.screen_save -p

  term.erase_saved_lines -p
  read -r g_tty_height g_tty_width < <(stty size)
}

tty.fullscreen_deinit() {
  term.screen_restore -p
  term.cursor_restorepos -p
  term.cursor_show -p
  stty echo
}

tty.all_save() {
  term.cursor_savepos -p
  term.screen_save -p
}

tty.all_restore() {
  term.screen_restore -p
  term.cursor_restorepos -p
}

# backwards
tty._backwards_all() {
  value_idx=0
}

tty._backwards_full_screen() {
  if ((value_idx - g_tty_height > 0)); then
    value_idx=$((value_idx - g_tty_height))
  else
    value_idx=0
  fi
}

tty._backwards_half_screen() {
  if ((value_idx - (g_tty_height/2) > 0)); then
    value_idx=$((value_idx - (g_tty_height/2)))
  else
    value_idx=0
  fi
}

tty._backwards_one() {
  if ((value_idx > 0)); then
    value_idx=$((value_idx-1))
  fi
}

# forwards
tty._forwards_full_screen() {
  local array_length=$1

  if ((value_idx + g_tty_height < array_length)); then
    value_idx=$((value_idx + g_tty_height))
  else
    value_idx=$((array_length-1))
  fi
}

tty._forwards_half_screen() {
  local array_length=$1

  if ((value_idx + (g_tty_height/2) < array_length)); then
    value_idx=$((value_idx + (g_tty_height/2)))
  else
    value_idx=$((array_length-1))
  fi
}

tty._forwards_one() {
  local array_length=$1

  if ((value_idx+1 < array_length)); then
    value_idx=$((value_idx+1))
  fi
}

tty._forwards_all() {
  local array_length=$1

  value_idx=$((array_length-1))
}

tty._print_list() {
  local index="$1"
  if ! shift; then
    display_error 'Failed to shift'
    exit 1
  fi

  # index represents the center (ex. 17)

  local start=$((index - (g_tty_height / 2)))
  local end=$((start + g_tty_height))

  term.cursor_to -p 0 0

  local i=
  local str=
  local prefix=
  for ((i=start; i<end; i++)); do
    if ((i != start)); then
      term.cursor_down -p 1
    fi

    if ((index+1 == i)); then
      prefix='> '
    else
      prefix='  '
    fi

    # Greater than zero since "$0"
    if ((i > 0 && i<$#+1)); then
      str="${prefix}${*:$i:1}"
    else
      str="${prefix}\033[1;30m~\033[0m"
    fi

    printf '\r'
    term.erase_line_end -p
    # shellcheck disable=SC2059
    printf "$str"
  done; unset -v i
}

tty.array_select() {
  unset -v REPLY; REPLY=
  local initial_value="$1"
  local arr_name="$2"
  local -n arr="$arr_name"

  if (( ${#arr[@]} == 0)); then
    display_error "Array must not be empty"
    exit 1
  fi

  local value_is_in_array=no
  local value_idx=
  local i=
  for ((i=0; i < ${#arr[@]}; i++)); do
    if [ "${arr[$i]}" = "$initial_value" ]; then
      value_is_in_array=yes
      value_idx=$i
      break
    fi
  done; unset -v i
  if [ "$value_is_in_array" = 'no' ]; then
    display_error "Value '$initial_value' not found in array '$arr_name'"
    exit 1
  fi
  unset -v value_is_in_array

  declare -g g_tty_height
  declare -g g_tty_width
  tty.fullscreen_init
  trap.sigint_tty() {
    tty.fullscreen_deinit
  }
  trap.sigcont_tty() {
    tty.fullscreen_init
  }
  trap 'trap.sigint_tty' 'EXIT'
  trap 'trap.sigcont_tty' 'SIGCONT'

  tty._print_list "$value_idx" "${arr[@]}"
  while :; do
    local key=
    if ! read -rsN1 key; then
      display_error 'Could not read input'
      exit 1
    fi

    case $key in
    g) tty._backwards_all ;;
    $'\x02') tty._backwards_full_screen ;; # C-b
    $'\x15') tty._backwards_half_screen ;; # C-u
    k|$'\x10') tty._backwards_one ;; # k, C-p
    $'\x06') tty._forwards_full_screen ${#arr[@]} ;; # C-f
    $'\x04') tty._forwards_half_screen ${#arr[@]} ;; # C-d
    j|$'\x0e') tty._forwards_one ${#arr[@]} ;; # j, C-n
    G) tty._forwards_all ${#arr[@]} ;;
    $'\n'|$'\x0d') break ;; # enter (success)
    q|$'\x7f') # q, backspace (fail)
      break
      ;;
    $'\x1b') # escape
      if ! read -rsN1 -t 0.1 key; then
        # escape (fail)
        break
      fi

      case $key in
      $'\x5b')
        if ! read -rsN1 -t 0.1 key; then
          # escape (fail)
          break
        fi

        case $key in
        $'\x41') tty._backwards_one ;; # up
        $'\x42') tty._forwards_one ${#arr[@]} ;; # down
        $'\x43') tty._forwards_one ${#arr[@]} ;; # right
        $'\x44') tty._backwards_one ;; # left
        $'\x48') tty._backwards_all ;; # home
        $'\x46') tty._forwards_all ${#arr[@]} ;; # end
        $'\x35')
          if ! read -rsN1 -t 0.1 key; then
            # escape (fail)
            break
          fi

          case $key in
          $'\x7e') tty._backwards_full_screen ;; # pageup
          esac
          ;;
        $'\x36')
          if ! read -rsN1 -t 0.1 key; then
            # escape (fail)
            break
          fi

          case "$key" in
          $'\x7e') tty._forwards_full_screen ${#arr[@]} ;; # pagedown
          esac
        esac
        ;;
      esac
      ;;
    esac

    tty._print_list "$value_idx" "${arr[@]}"
  done
  unset -v key
  tty.fullscreen_deinit

  trap - 'EXIT'
  trap - 'SIGCONT'

  REPLY=${arr[$value_idx]}
}
