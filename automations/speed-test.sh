#!/bin/zsh
# @pls.description: Measure the internet connection's download and upload speed
# @pls.example: how fast is my internet?
# @pls.example: run a speed test
# @pls.example: is the connection slow?

echo "Testing for about 10 seconds…"
summary=$(networkQuality 2>&1) || { print -r -- "$summary" >&2; exit 1; }
download=$(print -r -- "$summary" | awk -F': ' '/^Downlink capacity/ {printf "%.0f %s", $2, substr($2, index($2, " ") + 1)}')
upload=$(print -r -- "$summary" | awk -F': ' '/^Uplink capacity/ {printf "%.0f %s", $2, substr($2, index($2, " ") + 1)}')
responsiveness=$(print -r -- "$summary" | awk -F': ' '/^Responsiveness/ {split($2, parts, " \\("); print parts[1]}')
echo "Download $download · Upload $upload · Responsiveness ${responsiveness:l}"
