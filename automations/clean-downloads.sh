#!/bin/zsh
# @pls.description: Trash old files in Downloads that haven't changed for a number of days, to free up space
# @pls.param days: int(1...3650) = 30 -- Only items unchanged for at least this many days
# @pls.param folder: path = ~/Downloads -- The folder to clean, when the request names another one
# @pls.confirm: true
# @pls.preview: true
# @pls.example: clean up my downloads
# @pls.example: clear out downloads older than a week
# @pls.example: my downloads folder is a mess

if [[ ! -d $PLS_FOLDER ]]; then
  echo "No folder at $PLS_FOLDER." >&2
  exit 1
fi

# Top-level items (not hidden ones) last changed more than `days` days ago.
items=("$PLS_FOLDER"/*(Nm+$(( PLS_DAYS - 1 ))))
if (( ${#items} == 0 )); then
  echo "Nothing in ${PLS_FOLDER/#$HOME/~} is older than $PLS_DAYS days."
  exit 0
fi

kilobytes=$(du -sk "${items[@]}" | awk '{total += $1} END {print total}')
size=$(awk -v kb="$kilobytes" 'BEGIN {
  if (kb >= 1048576) printf "%.1f GB", kb / 1048576; else if (kb >= 1024) printf "%.0f MB", kb / 1024; else printf "%d KB", kb
}')
if [[ -n $PLS_PREVIEW ]]; then
  echo "Would move ${#items} item(s) ($size) from ${PLS_FOLDER/#$HOME/~} to the Trash, e.g. ${items[1]:t}."
  exit 0
fi
trash "${items[@]}" || exit 1
echo "Moved ${#items} item(s) ($size) from ${PLS_FOLDER/#$HOME/~} to the Trash."
