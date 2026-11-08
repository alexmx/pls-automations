#!/bin/zsh
# @pls.name: Simulator appearance
# @pls.description: Switch the running iOS simulators to dark or light mode, or change their text size (Dynamic Type), to check how an app's UI holds up; or show the current settings
# @pls.param appearance: enum(dark|light|unchanged) = unchanged -- Dark or light mode, only when the request asks for one
# @pls.param text_size: enum(smallest|default|large|largest|accessibility-largest|unchanged) = unchanged -- The text size, only when the request asks for one
# @pls.example: simulator dark mode
# @pls.example: switch the simulator to light mode
# @pls.example: biggest text size in the simulator
# @pls.example: reset the simulator's text size
# @pls.example: what's the simulator's appearance?

# "<udid>\t<name>" per running simulator.
devices=$(xcrun simctl list devices booted | sed -nE 's/^ +(.*) \(([0-9A-F-]{36})\) \(Booted\) *$/\2	\1/p')
if [[ -z $devices ]]; then
  echo "No simulator is running; boot one with \`pls run simulators boot --device <name>\`." >&2
  exit 1
fi

case $PLS_TEXT_SIZE in
  smallest) size=extra-small ;;
  default) size=large ;;
  large) size=extra-large ;;
  largest) size=extra-extra-extra-large ;;
  accessibility-largest) size=accessibility-extra-extra-extra-large ;;
  *) size= ;;
esac

print -r -- "$devices" | while IFS=$'\t' read -r udid name; do
  [[ $PLS_APPEARANCE != unchanged ]] && { xcrun simctl ui "$udid" appearance "$PLS_APPEARANCE" || exit 1; }
  [[ -n $size ]] && { xcrun simctl ui "$udid" content_size "$size" || exit 1; }
  echo "$name: $(xcrun simctl ui "$udid" appearance), text $(xcrun simctl ui "$udid" content_size)"
done
