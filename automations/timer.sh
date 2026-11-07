#!/bin/zsh
# @pls.description: Set a quick timer that notifies you with a sound after a number of minutes
# @pls.param minutes: int(1...600) -- How long, in minutes
# @pls.param label: string = Timer -- What the timer is for, only when the request names it
# @pls.example: set a timer for 10 minutes
# @pls.example: timer 25 minutes for tea
# @pls.example: tell me when 5 minutes are up

label=$PLS_LABEL
# Runs in the background, so the terminal is free; it runs late if the Mac sleeps meanwhile.
nohup zsh -c '
  sleep $(( $1 * 60 ))
  osascript -e "on run argv" -e "display notification (item 1 of argv) with title \"Time is up\"" -e "end run" "$2"
  afplay /System/Library/Sounds/Glass.aiff
' timer "$PLS_MINUTES" "$label" >/dev/null 2>&1 &

echo "Timer set: $label at $(date -v+${PLS_MINUTES}M +%H:%M)."
