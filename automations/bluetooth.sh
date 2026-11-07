#!/bin/zsh
# @pls.description: Turn Bluetooth on or off, or restart it
# @pls.param mode: enum(on|off|toggle|restart) = toggle -- What to do with Bluetooth; restart turns it off and on again
# @pls.example: turn off bluetooth
# @pls.example: bluetooth on
# @pls.example: my headphones won't connect, restart bluetooth

# Runs the Shortcut "Set Bluetooth" with "on" or "off" as its input; macOS has no built-in Bluetooth command.
if ! shortcuts list | grep -qxF "Set Bluetooth"; then
  echo "There's no Shortcut named \"Set Bluetooth\" yet; build it in the Shortcuts app first." >&2
  exit 1
fi

set_bluetooth() {
  local input
  input=$(mktemp -t pls-bluetooth) || exit 1
  print -r -- "$1" > "$input"
  shortcuts run "Set Bluetooth" --input-path "$input"
  local result=$?
  rm -f "$input"
  return $result
}

mode=$PLS_MODE
if [[ $mode == toggle ]]; then
  state=$(system_profiler SPBluetoothDataType 2>/dev/null | grep -m1 'State:')
  [[ $state == *On* ]] && mode=off || mode=on
fi

case $mode in
  restart) set_bluetooth off && sleep 2 && set_bluetooth on && echo "Bluetooth restarted." ;;
  *) set_bluetooth $mode && echo "Bluetooth is $mode." ;;
esac
