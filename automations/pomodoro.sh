#!/bin/zsh
# @pls.description: Run Pomodoro focus sessions, work and break rounds with a notification at each switch, or stop them
# @pls.param minutes: int(5...120) = 25 -- Length of each work round, in minutes
# @pls.param rounds: int(0...12) = 4 -- How many work rounds; 0 stops the current session
# @pls.param break_minutes: int(1...60) = 5 -- Length of each break, in minutes
# @pls.background: true
# @pls.example: start a pomodoro
# @pls.example: pomodoro 50 minutes, 2 rounds
# @pls.example: focus session with 10 minute breaks
# @pls.example: stop the pomodoro

# A background job: starting it again replaces the one running, so 0 rounds just ends it.
if (( PLS_ROUNDS == 0 )); then
  echo "Pomodoro stopped."
  exit 0
fi

total=$(( PLS_MINUTES * PLS_ROUNDS + PLS_BREAK_MINUTES * (PLS_ROUNDS - 1) ))
echo "Pomodoro: $PLS_ROUNDS × $PLS_MINUTES min with $PLS_BREAK_MINUTES min breaks, done at $(date -v+${total}M +%H:%M)."

notify() { osascript -e "on run argv" -e "display notification (item 2 of argv) with title (item 1 of argv)" -e "end run" "$1" "$2"; afplay /System/Library/Sounds/$3.aiff; }
for round in {1..$PLS_ROUNDS}; do
  notify "Work round $round of $PLS_ROUNDS" "$PLS_MINUTES minutes of focus" Glass
  sleep $(( PLS_MINUTES * 60 ))
  if (( round < PLS_ROUNDS )); then
    notify "Break" "$PLS_BREAK_MINUTES minutes" Purr
    sleep $(( PLS_BREAK_MINUTES * 60 ))
  fi
done
notify "Pomodoro done" "$PLS_ROUNDS rounds finished" Hero
