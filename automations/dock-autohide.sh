#!/bin/zsh
# @pls.description: Turn Dock auto-hiding on or off
# @pls.param mode: enum(on|off|toggle) = toggle -- on hides the Dock until the pointer reaches it; off always shows it
# @pls.example: hide the dock
# @pls.example: always show the dock
# @pls.example: the dock keeps getting in the way

current=$(defaults read com.apple.dock autohide 2>/dev/null)
case $PLS_MODE in
  on) hide=true ;;
  off) hide=false ;;
  toggle) [[ $current == (1|true|TRUE|YES|yes) ]] && hide=false || hide=true ;;
esac

defaults write com.apple.dock autohide -bool $hide
killall Dock
[[ $hide == true ]] && echo "The Dock now hides itself." || echo "The Dock now always shows."
