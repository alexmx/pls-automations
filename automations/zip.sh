#!/bin/zsh
# @pls.name: Zip
# @pls.description: Zip a file or folder into a .zip archive next to it
# @pls.param item: path -- The file or folder to zip
# @pls.example: zip ~/Projects/site
# @pls.example: make a zip of the folder report
# @pls.example: compress this folder into an archive

if [[ ! -e $PLS_ITEM ]]; then
  echo "Nothing at $PLS_ITEM." >&2
  exit 1
fi
item=${PLS_ITEM%/}
out="$item.zip"
n=2
while [[ -e $out ]]; do
  out="$item $n.zip"
  (( n++ ))
done

# The same archive Finder's Compress makes.
ditto -c -k --sequesterRsrc --keepParent "$item" "$out" || exit 1
size=$(stat -f %z "$out" | awk '{ if ($1 >= 1048576) printf "%.1f MB", $1 / 1048576; else printf "%.0f KB", $1 / 1024 }')
echo "Created ${out/#$HOME/~} ($size)."
