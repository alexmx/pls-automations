#!/bin/zsh
# @pls.description: Create a note in Apple Notes and open it
# @pls.param title: string -- The note's title; when the request gives none, its first few words
# @pls.param body: string? -- The note's text, when the request gives some beyond the title
# @pls.example: new note called groceries
# @pls.example: make a note titled Ideas that says call mom
# @pls.example: jot down a note: buy milk

# Notes stores HTML: escape the text, then title as a heading and the body below it.
escape() { print -r -- "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' }
html="<h1>$(escape "$PLS_TITLE")</h1>"
[[ -n $PLS_BODY ]] && html+="<p>$(escape "$PLS_BODY")</p>"

output=$(osascript - "$html" 2>&1 <<'APPLESCRIPT'
on run argv
	tell application "Notes"
		set newNote to make new note with properties {body:item 1 of argv}
		show newNote
		activate
	end tell
end run
APPLESCRIPT
)
if (( $? != 0 )); then
  print -r -- "$output" | sed -E 's/^.*execution error: //; s/ \(-?[0-9]+\)$//' >&2
  exit 1
fi
echo "Created the note \"$PLS_TITLE\"."
