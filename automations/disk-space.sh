#!/bin/zsh
# @pls.description: Show how much free disk space is left on each drive
# @pls.example: how much disk space is free?
# @pls.example: is my disk full?
# @pls.example: how much storage do I have left

human() { awk -v kb="$1" 'BEGIN { if (kb >= 1073741824) printf "%.1f TB", kb / 1073741824; else if (kb >= 1048576) printf "%.0f GB", kb / 1048576; else printf "%.0f MB", kb / 1024 }' }
report() {  # <name> <mount point>
  local line=(${=$(df -k "$2" | awk 'NR == 2 {print $2, $4}')})
  local total=$line[1] free=$line[2]
  (( total > 0 )) || return
  echo "$1: $(human $free) free of $(human $total) ($(( (total - free) * 100 / total ))% used)"
}

# The startup disk's space is the data volume's, under its own name.
report "$(diskutil info / | awk -F': *' '/Volume Name/ {print $2}')" /System/Volumes/Data
# Other drives and disk images you mounted, not the recovery volume.
for mount in /Volumes/*(N/); do
  [[ ${mount:t} == Recovery ]] && continue
  df -k "$mount" 2>/dev/null | awk 'NR == 2 {exit !($NF == m)}' m="$mount" && report "${mount:t}" "$mount"
done
