#!/bin/zsh
# @pls.name: Ghostty jump
# @pls.description: Go to the open Ghostty terminal in a folder, or with a title, by bringing it to the front
# @pls.param name: string -- The folder's name or path, or text in the terminal's title
# @pls.example: go to the terminal in ark
# @pls.example: take me to the pane in ~/Projects/quick
# @pls.example: switch to the lazygit terminal
# @pls.example: jump to my codechat terminal

# One line per terminal: id, tty, folder and title, split by the unit separator (character id 31), which can't be in
# any of them and, unlike a tab, keeps empty fields.
list=$(osascript 2>&1 <<'APPLESCRIPT'
set sep to character id 31
set out to ""
tell application "Ghostty"
	repeat with t in terminals
		set out to out & (id of t) & sep & (tty of t) & sep & (working directory of t) & sep & (name of t) & linefeed
	end repeat
end tell
return out
APPLESCRIPT
)
if (( $? != 0 )); then
  if [[ $list == *"-1708"* || $list == *"-2741"* || $list == *"-1728"* ]]; then
    echo "Ghostty can't be scripted here; it needs Ghostty 1.3 or later." >&2
  else
    print -r -- "$list" >&2
  fi
  exit 1
fi

sep=$'\x1f'
needle=${${PLS_NAME/#\~/$HOME}%/}
needle=${needle:l}
# The terminal pls runs in, which shouldn't be the answer when another one matches.
self=/dev/$(ps -o tty= -p $$ | tr -d ' ')

# Best first: the folder is the name (or ends with it as a path), then the folder or title contains it.
typeset -a exact partial
for line in ${(f)list}; do
  IFS=$sep read -r id tty dir title <<< "$line"
  if [[ ${dir:l} == $needle || ${dir:l} == */$needle ]]; then
    exact+=("$line")
  elif [[ ${dir:l} == *$needle* || ${title:l} == *$needle* ]]; then
    partial+=("$line")
  fi
done
if (( ${#exact} )); then matches=("${exact[@]}"); else matches=("${partial[@]}"); fi

describe() {
  local id tty dir title
  IFS=$sep read -r id tty dir title <<< "$1"
  print -r -- "${dir/#$HOME/~}  ($title)"
}

if (( ${#matches} == 0 )); then
  echo "No Ghostty terminal is in a folder or titled like \"$PLS_NAME\". Open ones:" >&2
  for line in ${(f)list}; do echo "  $(describe "$line")" >&2; done
  exit 1
fi

others=("${(@)matches:#*$sep$self$sep*}")
(( ${#others} )) && matches=("${others[@]}")
chosen=$matches[1]
IFS=$sep read -r id _ <<< "$chosen"

if ! error=$(osascript - "$id" 2>&1 <<'APPLESCRIPT'
on run argv
	tell application "Ghostty" to focus (first terminal whose id is (item 1 of argv))
end run
APPLESCRIPT
); then
  print -r -- "$error" >&2
  exit 1
fi
echo "Went to $(describe "$chosen")."
if (( ${#matches} > 1 )); then
  echo "Also matching:"
  for line in "${(@)matches[2,-1]}"; do echo "  $(describe "$line")"; done
fi
