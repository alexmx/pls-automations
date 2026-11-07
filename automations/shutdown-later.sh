#!/bin/zsh
# @pls.description: Shut down or restart the Mac now or after some minutes, or cancel a pending one
# @pls.param action: enum(shutdown|restart|cancel) = shutdown -- What to do; cancel stops a pending shutdown or restart
# @pls.param minutes: int(0...600) = 0 -- Minutes from now; 0 means right away
# @pls.confirm: action=shutdown,restart
# @pls.background: true
# @pls.example: shut down in an hour
# @pls.example: restart the mac
# @pls.example: turn off the computer in 90 minutes when the movie ends
# @pls.example: cancel the shutdown

# A background job: starting it again replaces the one pending, so cancel just ends it.
if [[ $PLS_ACTION == cancel ]]; then
  echo "Cancelled any pending shutdown or restart."
  exit 0
fi

# System Events shuts down the normal way, so apps can save or ask about unsaved work.
[[ $PLS_ACTION == restart ]] && command="restart" || command="shut down"
verb=$([[ $PLS_ACTION == restart ]] && print "Restarting" || print "Shutting down")
if (( PLS_MINUTES > 0 )); then
  echo "$verb at $(date -v+${PLS_MINUTES}M +%H:%M); \`pls jobs stop shutdown-later\` cancels it."
  sleep $(( PLS_MINUTES * 60 ))
else
  echo "$verb now."
fi
osascript -e "tell application \"System Events\" to $command"
