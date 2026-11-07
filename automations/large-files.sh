#!/bin/zsh
# @pls.description: List the biggest files in a folder and its subfolders, to see what's taking up space
# @pls.param folder: path = ~ -- The folder to search
# @pls.param count: int(1...100) = 20 -- How many files to list
# @pls.example: what's taking up space?
# @pls.example: biggest files in ~/Downloads
# @pls.example: find large files on my mac

folder=${PLS_FOLDER%/}
if [[ ! -d $folder ]]; then
  echo "No folder at $PLS_FOLDER." >&2
  exit 1
fi
echo "Searching ${folder/#$HOME/~}…" >&2

# Skips ~/Library and hidden files and folders, unless the folder asked for is one of them.
find "$folder" -mindepth 1 \( -path "$HOME/Library" -o -name '.*' \) -prune -o -type f -print0 2>/dev/null \
  | xargs -0 stat -f '%z%t%N' 2>/dev/null \
  | sort -rn | head -n "$PLS_COUNT" \
  | awk -F '\t' -v home="$HOME" '{
      size = $1
      if (size >= 1073741824) human = sprintf("%.1f GB", size / 1073741824)
      else if (size >= 1048576) human = sprintf("%.0f MB", size / 1048576)
      else human = sprintf("%.0f KB", size / 1024)
      path = $2; if (index(path, home) == 1) path = "~" substr(path, length(home) + 1)
      printf "%8s  %s\n", human, path
    }'
