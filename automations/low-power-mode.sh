#!/bin/zsh
# @pls.description: Turn Low Power Mode on or off to save battery
# @pls.param mode: enum(on|off|toggle) = toggle -- on saves battery; off gives full performance
# @pls.example: turn on low power mode
# @pls.example: save battery
# @pls.example: I need full performance

# Changing it needs sudo, so it asks for your password unless sudo remembers it.
mode=$PLS_MODE
if [[ $mode == toggle ]]; then
  [[ $(pmset -g | awk '/lowpowermode/ {print $2}') == 1 ]] && mode=off || mode=on
fi
[[ $mode == on ]] && value=1 || value=0

sudo pmset -a lowpowermode $value && echo "Low Power Mode is $mode."
