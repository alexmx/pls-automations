#!/bin/zsh
# @pls.name: Ghostty split
# @pls.description: Split the current Ghostty pane, opening the new pane in the current folder, and run a command in it if one is given
# @pls.param direction: enum(right|down|left|up) = right -- Which side of the current pane the new one goes
# @pls.param command: string? -- A command to run in the new pane
# @pls.example: split right
# @pls.example: split down and run npm test
# @pls.example: open a pane below running npm run dev
# @pls.example: split the terminal to the left

# The front window's focused pane: where pls runs when you ask from Ghostty. The command is typed into the new pane's
# shell, so it can be stopped and the shell stays.
output=$(osascript - "$PLS_DIRECTION" "$PLS_COMMAND" "$PWD" 2>&1 <<'APPLESCRIPT'
on run argv
	set side to item 1 of argv
	set cmd to item 2 of argv
	set workDir to item 3 of argv
	tell application "Ghostty"
		if (count of windows) is 0 then error "Ghostty has no window open to split."
		set activePane to focused terminal of selected tab of front window
		set cfg to new surface configuration
		set initial working directory of cfg to workDir
		if side is "down" then
			set newPane to split activePane direction down with configuration cfg
		else if side is "left" then
			set newPane to split activePane direction left with configuration cfg
		else if side is "up" then
			set newPane to split activePane direction up with configuration cfg
		else
			set newPane to split activePane direction right with configuration cfg
		end if
		if cmd is not "" then input text cmd & linefeed to newPane
		focus newPane
	end tell
end run
APPLESCRIPT
)
if (( $? != 0 )); then
  if [[ $output == *"no window open"* ]]; then
    echo "Ghostty has no window open to split." >&2
  elif [[ $output == *"-1708"* || $output == *"-2741"* || $output == *"-1728"* ]]; then
    echo "Ghostty can't be scripted here; it needs Ghostty 1.3 or later." >&2
  else
    print -r -- "$output" >&2
  fi
  exit 1
fi
echo "Split ${PLS_DIRECTION}${PLS_COMMAND:+, running $PLS_COMMAND}."
