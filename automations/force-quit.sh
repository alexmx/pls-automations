#!/bin/zsh
# @pls.description: Force-quit one app that's frozen or not responding, losing its unsaved work
# @pls.param app: string -- The app's name
# @pls.confirm: true
# @pls.preview: true
# @pls.example: force quit Xcode
# @pls.example: Chrome is frozen, kill it
# @pls.example: Spotify isn't responding

# Open apps as "<name>\t<pid>" lines.
apps=$(osascript -e 'tell application "System Events"
  set out to ""
  repeat with p in (every application process whose background only is false)
    set out to out & name of p & tab & unix id of p & linefeed
  end repeat
  return out
end tell')

wanted=${PLS_APP:l}
# The exact name (any case) first, else the one open app whose name contains it ("chrome" → Google Chrome).
match=$(print -r -- "$apps" | awk -F '\t' -v w="$wanted" 'tolower($1) == w')
[[ -z $match ]] && match=$(print -r -- "$apps" | awk -F '\t' -v w="$wanted" 'index(tolower($1), w)')
if [[ -z $match ]]; then
  echo "No open app called $PLS_APP. Open: $(print -r -- "$apps" | cut -f1 | sort -u | paste -sd ',' - | sed 's/,/, /g')." >&2
  exit 1
fi
if (( $(print -r -- "$match" | cut -f1 | sort -u | wc -l) > 1 )); then
  echo "Several open apps match $PLS_APP: $(print -r -- "$match" | cut -f1 | sort -u | paste -sd ',' - | sed 's/,/, /g'). Name one exactly." >&2
  exit 1
fi

name=$(print -r -- "$match" | head -1 | cut -f1)
if [[ -n $PLS_PREVIEW ]]; then
  echo "Would force-quit $name, losing its unsaved work."
  exit 0
fi
for pid in $(print -r -- "$match" | cut -f2); do kill -9 "$pid"; done
echo "Force-quit $name."
