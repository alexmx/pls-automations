#!/bin/zsh
# @pls.description: Turn a macOS Focus mode on or off, optionally for a number of minutes
# @pls.param mode: enum(do-not-disturb|work|personal|sleep|morning|reduce-interruptions|off) = do-not-disturb -- Which Focus to turn on, or off to end the current one
# @pls.param minutes: int(0...1440) = 0 -- How long, in minutes; 0 means until turned off
# @pls.example: do not disturb for an hour
# @pls.example: turn off focus
# @pls.example: I'm going to bed
# @pls.example: work mode until lunch, about 2 hours

# Runs the Shortcut "Set Focus", which takes {"mode": ..., "minutes": ...} as its input.
if ! shortcuts list | grep -qxF "Set Focus"; then
  echo "There's no Shortcut named \"Set Focus\" yet; build it in the Shortcuts app first." >&2
  exit 1
fi

input=$(mktemp -t pls-focus) || exit 1
trap 'rm -f "$input"' EXIT
printf '{"mode": "%s", "minutes": %s}\n' "$PLS_MODE" "$PLS_MINUTES" > "$input"
shortcuts run "Set Focus" --input-path "$input" || exit $?
if [[ $PLS_MODE == off ]]; then
  echo "Focus is off."
elif (( PLS_MINUTES > 0 )); then
  echo "Focus $PLS_MODE is on until $(date -v+${PLS_MINUTES}M +%H:%M)."
else
  echo "Focus $PLS_MODE is on."
fi
