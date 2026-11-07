#!/bin/zsh
# @pls.description: Record the screen to a video file for a number of seconds, without sound
# @pls.param seconds: int(1...3600) = 30 -- How long to record
# @pls.param folder: path = ~/Desktop -- Where to save the video
# @pls.example: record my screen for a minute
# @pls.example: start a 2 minute screen recording
# @pls.example: capture the screen for 20 seconds

if [[ ! -d $PLS_FOLDER ]]; then
  echo "No folder at $PLS_FOLDER." >&2
  exit 1
fi
file="$PLS_FOLDER/Screen Recording $(date '+%Y-%m-%d at %H.%M.%S').mov"
echo "Recording for $PLS_SECONDS seconds… (Ctrl-C stops early)"
# Needs Screen Recording permission for the terminal (System Settings → Privacy & Security).
screencapture -x -V "$PLS_SECONDS" "$file" || exit 1
if [[ ! -s $file ]]; then
  echo "Nothing was recorded; check the terminal has Screen Recording permission." >&2
  exit 1
fi
echo "Saved ${file/#$HOME/~}."
