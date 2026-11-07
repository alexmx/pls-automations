#!/bin/zsh
# @pls.name: Time Machine backup now
# @pls.description: Start a Time Machine backup now, or show when the last one finished
# @pls.param action: enum(start|status) = start -- start a backup, or status to see the last one
# @pls.example: back up my mac now
# @pls.example: start a time machine backup
# @pls.example: when was my last backup?

prefs=/Library/Preferences/com.apple.TimeMachine.plist
if ! tmutil destinationinfo >/dev/null 2>&1; then
  echo "Time Machine isn't set up; choose a backup disk in System Settings → General → Time Machine." >&2
  exit 1
fi

# The newest date in a list of the first destination's dates, as "Sep 4, 21:42 (64 days ago)"; read from the settings
# file, so it works while a network backup disk is out of reach.
newest() {
  local stamp=$(plutil -extract "Destinations.0.$1" xml1 -o - "$prefs" 2>/dev/null | sed -nE 's/.*<date>(.*)<\/date>.*/\1/p' | tail -1)
  [[ -z $stamp ]] && { print never; return }
  local seconds=$(date -j -u -f '%Y-%m-%dT%H:%M:%SZ' "$stamp" +%s)
  local days=$(( ($(date +%s) - seconds) / 86400 ))
  print "$(date -r "$seconds" '+%b %-d, %H:%M') ($( (( days == 0 )) && print today || print "$days days ago"))"
}

if [[ $PLS_ACTION == status ]]; then
  running=$(tmutil status | awk -F' = ' '/Running/ {gsub(/;/, "", $2); print $2}')
  echo "Last finished backup: $(newest SnapshotDates). Last attempt: $(newest AttemptDates)."
  [[ $running == 1 ]] && echo "A backup is running now."
  exit 0
fi

tmutil startbackup --auto || exit 1
echo "Time Machine backup started; \`pls run time-machine-backup-now status\` shows how it went."
