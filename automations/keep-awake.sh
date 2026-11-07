#!/bin/zsh
# @pls.description: Keep the Mac and its display awake for a number of minutes, or let it sleep again
# @pls.param minutes: int(0...1440) = 60 -- How long to stay awake, in minutes; 0 lets it sleep again
# @pls.background: true
# @pls.example: keep my mac awake for 2 hours
# @pls.example: don't let the screen sleep during the presentation
# @pls.example: let the mac sleep again

# A background job: starting it again replaces the one running, so 0 just ends it.
if (( PLS_MINUTES == 0 )); then
  echo "Sleep is allowed again."
  exit 0
fi
echo "Staying awake until $(date -v+${PLS_MINUTES}M +%H:%M)."
exec caffeinate -d -t $(( PLS_MINUTES * 60 ))
