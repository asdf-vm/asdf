# shellcheck shell=bash

# This file is a bundled version of [bash-term](https://github.com/bash-bastion/bash-term) v0.6.3.
# bash-term is a Bash library for printing terminal escape sequences. bash-term is used instead of
# tput because it is significantly faster (and easier to use).

# Functions part of the public interface have [shdoc](https://github.com/reconquest/shdoc/issues) annotations.
# Do not use functions without these; they are prefixed with 'private' or an underscore.

# -------------------------------------------------------- #
#                          Cursor                          #
# -------------------------------------------------------- #

# @description Move the cursor position to a supplied row and column. Both default to `0` if not supplied
# @arg $1 int row
# @arg $1 int column
term.cursor_to() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 2 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local row="${1:-0}"
	local column="${2:-0}"

	# Note that 'f' instead of 'H' is the 'force' variant
	term.private_util_set_reply2 '\033[%s;%sH' "$row" "$column"
}

# @description Moves cursor position to a supplied _relative_ row and column. Both default to `0` if not supplied (FIXME: implement)
# @arg $1 int row
# @arg $1 int column
term.cursor_moveto() {
	:
}

# @description Moves the cursor up. Defaults to `1` if not supplied
# @arg $1 int count
term.cursor_up() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local count="${1:-1}"

	term.private_util_set_reply2 '\033[%sA' "$count"
}

# @description Moves the cursor down. Defaults to `1` if not supplied
# @arg $1 int count
term.cursor_down() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local count="${1:-1}"

	term.private_util_set_reply2 '\033[%sB' "$count"
}

# @description Moves the cursor forward. Defaults to `1` if not supplied
# @arg $1 int count
term.cursor_forward() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local count="${1:-1}"

	term.private_util_set_reply2 '\033[%sC' "$count"
}

# @description Moves the cursor backwards. Defaults to `1` if not supplied
# @arg $1 int count
term.cursor_backward() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local count="${1:-1}"

	term.private_util_set_reply2 '\033[%sD' "$count"
}

# @description Moves the cursor to the next line. Defaults to `1` if not supplied
# @arg $1 int count
term.cursor_line_next() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local count="${1:-1}"

	term.private_util_set_reply2 '\033[%sE' "$count"
}

# @description Moves the cursor to the previous line. Defaults to `1` if not supplied
# @arg $1 int count
term.cursor_line_prev() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local count="${1:-1}"

	term.private_util_set_reply2 '\033[%sF' "$count"
}

# FIXME: docs
# @description Moves the cursor ?
# @arg $1 int count
term.cursor_horizontal() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local count="${1:-1}"

	term.private_util_set_reply2 '\033[%sG' "$count"
}

# @description Saves the current cursor position
# @noargs
term.cursor_savepos() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 0 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	if [ "$TERM_PROGRAM" = 'Apple_Terminal' ]; then
		REPLY=$'\u001B7'
	else
		REPLY=$'\e[s'
	fi
	term.private_util_replyprint
}

# @description Restores cursor to the last saved position
# @noargs
term.cursor_restorepos() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 0 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	if [ "$TERM_PROGRAM" = 'Apple_Terminal' ]; then
		REPLY=$'\u001B8'
	else
		REPLY=$'\e[u'
	fi
	term.private_util_replyprint
}

# FIXME: docs
# @description Saves
# @noargs
term.cursor_save() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 0 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	term.private_util_set_reply $'\e[7'
}

# FIXME: docs
# @description Restores
# @noargs
term.cursor_restore() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 0 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	term.private_util_set_reply $'\e[8'
}

# @description Hides the cursor
# @noargs
term.cursor_hide() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 0 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	term.private_util_set_reply $'\e[?25l'
}

# @description Shows the cursor
# @noargs
term.cursor_show() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 0 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	term.private_util_set_reply $'\e[?25h'
}

# @description Reports the cursor position to the application as (as though typed at the keyboard)
# @noargs
term.cursor_getpos() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 0 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	term.private_util_set_reply $'\e[6n'
}

# -------------------------------------------------------- #
#                           Erase                          #
# -------------------------------------------------------- #

# @description Erase from the current cursor position to the end of the current line
# @noargs
term.erase_line_end() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 0 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	# Same as '\e[0K'
	term.private_util_set_reply $'\e[K'
}

# @description Erase from the current cursor position to the start of the current line
# @noargs
term.erase_line_start() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 0 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	term.private_util_set_reply $'\e[1K'
}

# @description Erase the entire current line
# @noargs
term.erase_line() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 0 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	term.private_util_set_reply $'\e[2K'
}

# @description Erase the screen from the current line down to the bottom of the screen
# @noargs
term.erase_screen_end() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 0 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	# Same as '\e[0J'
	term.private_util_set_reply $'\e[J'
}

# @description Erase the screen from the current line up to the top of the screen
# @noargs
term.erase_screen_start() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 0 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	term.private_util_set_reply $'\e[1J'
}

# @description Erase the screen and move the cursor the top left position
# @noargs
term.erase_screen() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 0 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	term.private_util_set_reply $'\e[2J'
}

# @noargs
term.erase_saved_lines() { # TODO: better name?
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 0 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	term.private_util_set_reply $'\e[3J'
}

# -------------------------------------------------------- #
#                          Scroll                          #
# -------------------------------------------------------- #

# @noargs
term.scroll_down() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 0 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	# REPLY=$'\e[T'
	term.private_util_set_reply $'\e[D'
}

# @noargs
term.scroll_up() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 0 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	# REPLY=$'\e[S'
	term.private_util_set_reply $'\e[M'
}

# -------------------------------------------------------- #
#                            Tab                           #
# -------------------------------------------------------- #

# @noargs
term.tab_set() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 0 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	term.private_util_set_reply $'\e[H'
}

# @noargs
term.tab_clear() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 0 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	term.private_util_set_reply $'\e[g'
}

# @noargs
term.tab_clearall() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 0 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	term.private_util_set_reply $'\e[3g'
}

# -------------------------------------------------------- #
#                          Screen                          #
# -------------------------------------------------------- #

# @description Save screen
# @noargs
term.screen_save() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 0 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	term.private_util_set_reply $'\e[?1049h'
}

# @description Restore screen
# @noargs
term.screen_restore() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 0 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	term.private_util_set_reply $'\e[?1049l'
}

# -------------------------------------------------------- #
#                           Color                          #
# -------------------------------------------------------- #

# @description Construct reset
# @arg $1 string text
term.style_reset() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local text="$1"

	term.private_util_set_reply2 '\e[0m%s' "$text"
}

# @description Construct bold
# @arg $1 string text
term.style_bold() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_pd 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local text="$1"

	term.private_util_set_reply2 "\e[1m%s%s" "$text" "$end"
}

# @description Construct dim
# @arg $1 string text
term.style_dim() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_pd 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local text="$1"

	term.private_util_set_reply2 "\e[2m%s%s" "$text" "$end"
}

# @description Construct italic
# @arg $1 string text
term.style_italic() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_pd 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local text="$1"

	term.private_util_set_reply2 "\e[3m%s%s" "$text" "$end"
}

# @description Construct underline
# @arg $1 string text
term.style_underline() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_pd 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local text="$1"

	term.private_util_set_reply2 "\e[4m%s%s" "$text" "$end"
}

# @description Construct inverse
# @arg $1 string text
term.style_inverse() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_pd 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local text="$1"

	term.private_util_set_reply2 "\e[7m%s%s" "$text" "$end"
}

# @description Construct hidden
# @arg $1 string text
term.style_hidden() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_pd 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local text="$1"

	term.private_util_set_reply2 "\e[8m%s%s" "$text" "$end"
}

# @description Construct strikethrough
# @arg $1 string text
term.style_strikethrough() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_pd 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local text="$1"

	term.private_util_set_reply2 "\e[9m%s%s" "$text" "$end"
}

# @description Construct hyperlink
# @arg $1 string text
# @arg $2 string url
term.style_hyperlink() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 2 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local text="$1"
	local url="$2"

	term.private_util_set_reply2 '\e]8;;%s\a%s\e]8;;\a' "$url" "$text"
}

# @description Construct black color
# @arg $1 string text
term.color_black() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_pd 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local text="$1"

	term.private_util_set_reply2 "\e[30m%s%s" "$text" "$end"
}

# @description Construct red color
# @arg $1 string text
term.color_red() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_pd 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local text="$1"

	term.private_util_set_reply2 "\e[31m%s%s" "$text" "$end"
}

# @description Construct green color
# @arg $1 string text
term.color_green() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_pd 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local text="$1"

	term.private_util_set_reply2 "\e[32m%s%s" "$text" "$end"
}

# @description Construct orange color
# @arg $1 string text
term.color_orange() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_pd 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local text="$1"

	term.private_util_set_reply2 "\e[33m%s%s" "$text" "$end"
}

# @description Construct blue color
# @arg $1 string text
term.color_blue() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_pd 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local text="$1"

	term.private_util_set_reply2 "\e[34m%s%s" "$text" "$end"
}

# @description Construct purple color
# @arg $1 string text
term.color_purple() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_pd 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local text="$1"

	term.private_util_set_reply2 "\e[35m%s%s" "$text" "$end"
}

# @description Construct cyan color
# @arg $1 string text
term.color_cyan() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_pd 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local text="$1"

	term.private_util_set_reply2 "\e[36m%s%s" "$text" "$end"
}

# @description Construct light gray color
# @arg $1 string text
term.color_light_gray() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_pd 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local text="$1"

	term.private_util_set_reply2 "\e[37m%s%s" "$text" "$end"
}

# @description Construct dark gray color
# @arg $1 string text
term.color_dark_gray() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_pd 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local text="$1"

	term.private_util_set_reply2 "\e[1;30m%s%s" "$text" "$end"
}

# @description Construct light red color
# @arg $1 string text
term.color_light_red() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_pd 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local text="$1"

	term.private_util_set_reply2 "\e[1;31m%s%s" "$text" "$end"
}

# @description Construct light green color
# @arg $1 string text
term.color_light_green() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_pd 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local text="$1"

	term.private_util_set_reply2 "\e[1;32m%s%s" "$text" "$end"
}

# @description Construct yellow color
# @arg $1 string text
term.color_yellow() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_pd 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local text="$1"

	term.private_util_set_reply2 "\e[1;33m%s%s" "$text" "$end"
}

# @description Construct light blue color
# @arg $1 string text
term.color_light_blue() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_pd 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local text="$1"

	term.private_util_set_reply2 "\e[1;34m%s%s" "$text" "$end"
}

# @description Construct light purple color
# @arg $1 string text
term.color_light_purple() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_pd 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local text="$1"

	term.private_util_set_reply2 "\e[1;35m%s%s" "$text" "$end"
}

# @description Construct light cyan color
# @arg $1 string text
term.color_light_cyan() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_pd 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local text="$1"

	term.private_util_set_reply2 "\e[1;36m%s%s" "$text" "$end"
}

# @description Construct white color
# @arg $1 string text
term.color_white() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_pd 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	local text="$1"

	term.private_util_set_reply2 "\e[1;37m%s%s" "$text" "$end"
}

# -------------------------------------------------------- #
#                       Miscellaneous                      #
# -------------------------------------------------------- #

# @description Construct a beep
# @noargs
term.beep() {
	unset -v REPLY

	local flag_print='no' end=
	term.private_util_validate_p 1 "$@"
	shift "$REPLY_SHIFT" || core.panic 'Failed to shift'
	unset -v REPLY_SHIFT

	term.private_util_set_reply $'\a'
}

# -------------------------------------------------------- #
#                        Deprecated                        #
# -------------------------------------------------------- #

# @description (DEPRECATED) Construct hyperlink
# @arg $1 string text
# @arg $2 string url
term.hyperlink() {
	term.style_hyperlink "$@"
}

# @description (DEPRECATED) Construct bold
# @arg $1 string text
term.bold() {
	term.style_bold "$@"
}

# @description (DEPRECATED) Construct italic
# @arg $1 string text
term.italic() {
	term.style_italic "$@"
}

# @description (DEPRECATED) Construct underline
# @arg $1 string text
term.underline() {
	term.style_underline "$@"
}

# @description (DEPRECATED) Construct strikethrough
# @arg $1 string text
term.strikethrough() {
	term.style_strikethrough "$@"
}

term.private_util_validate_p() {
	local args_excluding_flags="$1"
	if ! shift; then core.panic 'Failed to shift'; fi

	if (($# - 1 > args_excluding_flags)); then
		core.panic 'Incorrect argument count'
	elif (($# - 1 == args_excluding_flags)); then
		if [[ $1 == -?(@(p|P)) ]]; then
			case $1 in
			*p*) flag_print='yes' ;;
			*P*) flag_print='yes-newline' ;;
			esac
			REPLY_SHIFT=1
		else
			core.panic 'Invalid flag'
		fi
	else
		REPLY_SHIFT=0
	fi

}

term.private_util_validate_pd() {
	local args_excluding_flags="$1"
	if ! shift; then core.panic 'Failed to shift'; fi

	if (($# - 1 == args_excluding_flags)); then
		if [[ $1 == -?(d|@(p|P)|d@(p|P)|@(p|P)d) ]]; then
			case $1 in
			*p*) flag_print='yes' ;;
			*P*) flag_print='yes-newline' ;;
			esac
			if [[ $1 == *d* ]]; then
				end=$'\e[0m'
			fi
			REPLY_SHIFT=1
		else
			core.panic 'Invalid flag'
		fi
	elif (($# > args_excluding_flags)); then
		core.panic 'Incorrect argument count'
	else
		REPLY_SHIFT=0
	fi
}

term.private_util_set_reply() {
	local value="$1"

	REPLY="$value"
	term.private_util_replyprint
}

term.private_util_set_reply2() {
	# shellcheck disable=SC2059
	printf -v REPLY "$@"
	term.private_util_replyprint
}

term.private_util_replyprint() {
	if [ "$flag_print" = 'yes' ]; then
		printf '%s' "$REPLY"
	elif [ "$flag_print" = 'yes-newline' ]; then
		printf '%s\n' "$REPLY"
	fi
}
