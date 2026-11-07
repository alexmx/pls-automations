#!/bin/zsh
# @pls.name: Pretty JSON
# @pls.description: Format the JSON on the clipboard with indentation, or say why it isn't valid JSON
# @pls.param indent: enum(2|4) = 2 -- Spaces per indentation level
# @pls.example: pretty print the json I copied
# @pls.example: format the clipboard json
# @pls.example: is the json in my clipboard valid?

json=$(pbpaste)
if [[ -z $json ]]; then
  echo "The clipboard has no text." >&2
  exit 1
fi

if command -v python3 >/dev/null && python3 -c '' 2>/dev/null; then
  formatted=$(print -r -- "$json" | python3 -I -m json.tool --indent "$PLS_INDENT" 2>&1)
else
  # No Python (it comes with Xcode's command-line tools): plutil can do it, always with 2 spaces.
  formatted=$(print -r -- "$json" | plutil -convert json -r -o - - 2>&1)
fi
if (( $? != 0 )); then
  echo "Not valid JSON: $formatted" >&2
  exit 1
fi
print -r -- "$formatted" | pbcopy
echo "Formatted the JSON on the clipboard ($(print -r -- "$formatted" | wc -l | tr -d ' ') lines)."
