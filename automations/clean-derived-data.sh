#!/bin/zsh
# @pls.name: Clean DerivedData
# @pls.description: Delete Xcode's DerivedData to fix stale builds and free up disk space
# @pls.confirm: true
# @pls.preview: true
# @pls.example: clear derived data
# @pls.example: Xcode is acting weird, nuke derived data
# @pls.example: free up Xcode space

derived_data=~/Library/Developer/Xcode/DerivedData
items=("$derived_data"/*(DN))
if (( ${#items} == 0 )); then
  echo "DerivedData is already empty."
  exit 0
fi

kilobytes=$(du -sk "$derived_data" | cut -f1)
freed=$(awk -v kb="$kilobytes" 'BEGIN { if (kb >= 1048576) printf "%.1f GB", kb / 1048576; else printf "%.0f MB", kb / 1024 }')
if [[ -n $PLS_PREVIEW ]]; then
  echo "Would delete ${#items} project build folder(s), freeing $freed."
  exit 0
fi
rm -rf -- "${items[@]}" || exit 1
echo "Freed $freed."
pgrep -xq Xcode && echo "Xcode is open: the next build starts from scratch."
exit 0
