#!/bin/zsh
# @pls.description: Check for macOS and Apple software updates, without installing anything
# @pls.example: are there any macOS updates?
# @pls.example: check for system updates
# @pls.example: is my mac up to date?

echo "Checking with Apple…" >&2
output=$(softwareupdate --list 2>&1)
if [[ $output == *"No new software available"* ]]; then
  echo "macOS is up to date."
  exit 0
fi

# Each update has a line like "	Title: macOS Tahoe 26.1, Version: 26.1, Size: 3456789KiB, Recommended: YES, Action: restart,"
updates=$(print -r -- "$output" | awk -F', ' '/Title: / {
  title = $1; sub(/.*Title: /, "", title)
  size = ""; restart = ""
  for (i = 2; i <= NF; i++) {
    if ($i ~ /^Size: /) { kib = $i; gsub(/[^0-9]/, "", kib); kib += 0; size = (kib >= 1048576) ? sprintf("%.1f GB", kib / 1048576) : sprintf("%.0f MB", kib / 1024) }
    if ($i ~ /Action: restart/) restart = ", needs a restart"
  }
  printf "  %s (%s%s)\n", title, size, restart
}')
if [[ -z $updates ]]; then
  print -r -- "$output" >&2
  exit 1
fi
echo "Updates available (install them in System Settings → General → Software Update):"
print -r -- "$updates"
