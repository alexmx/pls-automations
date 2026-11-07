#!/bin/zsh
# @pls.description: Show the battery level, whether it's charging, how long is left, and the battery's health
# @pls.example: how much battery do I have?
# @pls.example: is it charging?
# @pls.example: battery status

# pmset: "-InternalBattery-0 (id=…)	20%; charging; 2:55 remaining present: true"
line=$(pmset -g batt | grep -m1 'InternalBattery')
if [[ -z $line ]]; then
  echo "This Mac has no battery."
  exit 0
fi
level=$(print -r -- "$line" | grep -oE '[0-9]+%')
state=$(print -r -- "$line" | awk -F'; ' '{print $2}')
left=$(print -r -- "$line" | grep -oE '[0-9]+:[0-9]+ remaining' | cut -d' ' -f1)

case $state in
  charging) summary="$level, charging${left:+, $left until full}" ;;
  charged|finishing\ charge) summary="$level, charged" ;;
  discharging) summary="$level, on battery${left:+, about $left left}" ;;
  *) summary="$level, $state" ;;
esac
health=$(system_profiler SPPowerDataType 2>/dev/null | awk -F': ' '
  /Cycle Count/ {cycles = $2} /Condition/ {condition = $2} /Maximum Capacity/ {capacity = $2}
  END {if (cycles) printf "health %s (%s capacity, %s cycles)", tolower(condition), capacity, cycles}')
echo "$summary${health:+ · $health}"
