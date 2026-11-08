#!/bin/zsh
# @pls.name: Ghostty presentation window
# @pls.description: Open a new Ghostty window with a big font, for a demo or screen sharing; other windows keep theirs
# @pls.param size: int(10...72) = 24 -- The font size in points
# @pls.example: big terminal for a demo
# @pls.example: open a terminal with a large font
# @pls.example: presentation mode terminal at 32pt
# @pls.example: I'm screen sharing, give me a bigger terminal

output=$(osascript - "$PLS_SIZE" "$PWD" 2>&1 <<'APPLESCRIPT'
on run argv
	tell application "Ghostty"
		activate
		set cfg to new surface configuration
		set font size of cfg to ((item 1 of argv) as integer)
		set initial working directory of cfg to item 2 of argv
		new window with configuration cfg
	end tell
end run
APPLESCRIPT
)
if (( $? != 0 )); then
  if [[ $output == *"-1708"* || $output == *"-2741"* || $output == *"-1728"* ]]; then
    echo "Ghostty can't be scripted here; it needs Ghostty 1.3 or later." >&2
  else
    print -r -- "$output" >&2
  fi
  exit 1
fi
echo "Opened a Ghostty window at ${PLS_SIZE}pt; ⌘↩ makes it full screen."
