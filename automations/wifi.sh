#!/bin/zsh
# @pls.name: Wi-Fi
# @pls.description: Turn Wi-Fi on or off, or restart it
# @pls.param mode: enum(on|off|restart) = restart -- What to do with Wi-Fi; restart turns it off and on again
# @pls.example: turn off wifi
# @pls.example: wifi on
# @pls.example: the internet is flaky, restart wifi
# @pls.example: go offline

# The Wi-Fi interface is usually en0, but not on every Mac.
device=$(networksetup -listallhardwareports | awk '/Hardware Port: Wi-Fi/ {getline; print $2}')
if [[ -z $device ]]; then
  echo "This Mac has no Wi-Fi interface." >&2
  exit 1
fi

case $PLS_MODE in
  restart)
    networksetup -setairportpower "$device" off && sleep 2 && networksetup -setairportpower "$device" on \
      && echo "Wi-Fi restarted." ;;
  *) networksetup -setairportpower "$device" "$PLS_MODE" && echo "Wi-Fi is $PLS_MODE." ;;
esac
