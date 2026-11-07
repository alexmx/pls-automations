#!/bin/zsh
# @pls.name: Apple Music playlist
# @pls.description: Play a playlist from the Music app by name
# @pls.param name: string -- The playlist's name, or part of it
# @pls.param shuffle: bool = false -- true when the request says to shuffle
# @pls.example: play my Chill playlist
# @pls.example: shuffle Workout
# @pls.example: put on the Road Trip playlist
# @pls.example: play the Focus playlist

# "Chill playlist" means the playlist "Chill".
name=$(print -r -- "$PLS_NAME" | sed -E 's/ +[Pp]laylist$//')

# An exact name first, then any playlist whose name contains it (case doesn't matter).
output=$(osascript - "$name" "$PLS_SHUFFLE" 2>&1 <<'APPLESCRIPT'
on run argv
	set wanted to item 1 of argv
	tell application "Music"
		set found to (every user playlist whose name is wanted)
		if found is {} then set found to (every user playlist whose name contains wanted)
		if found is {} then
			set AppleScript's text item delimiters to ", "
			error "No playlist named " & wanted & ". Your playlists: " & ((name of every user playlist) as text)
		end if
		set chosen to item 1 of found
		set shuffle enabled to ((item 2 of argv) is "true")
		play chosen
		return name of chosen
	end tell
end run
APPLESCRIPT
)
if (( $? != 0 )); then
  # osascript writes "<file>:<range>: execution error: <message> (<code>)"; keep the message.
  print -r -- "$output" | sed -E 's/^.*execution error: //; s/ \(-?[0-9]+\)$//' >&2
  exit 1
fi
[[ $PLS_SHUFFLE == true ]] && echo "Playing $output, shuffled." || echo "Playing $output."
