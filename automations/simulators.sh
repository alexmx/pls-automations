#!/bin/zsh
# @pls.name: Simulators
# @pls.description: List, boot, shut down or erase iOS simulators
# @pls.param action: enum(list|boot|shutdown|erase) = list -- What to do; list shows them and which are running
# @pls.param device: string? -- A simulator's name, only when the request names one
# @pls.confirm: action=erase
# @pls.example: boot the iPhone 17 simulator
# @pls.example: shut down all simulators
# @pls.example: erase the iPad simulator
# @pls.example: which simulators do I have?

# "<name>\t<udid>\t<state>" per available simulator; names can contain parentheses, so anchor on the UDID.
rows=$(xcrun simctl list devices available | sed -nE 's/^ +(.*) \(([0-9A-F-]{36})\) \(([A-Za-z]+)\) *$/\1	\2	\3/p')

if [[ $PLS_ACTION == list ]]; then
  print -r -- "$rows" | awk -F '\t' '{ printf "%-28s %s\n", $1, ($3 == "Booted" ? "running" : "") }' | sort -u
  exit 0
fi
if [[ $PLS_ACTION == shutdown && -z $PLS_DEVICE ]]; then
  xcrun simctl shutdown all && echo "Shut down all simulators."
  exit
fi
if [[ -z $PLS_DEVICE ]]; then
  echo "Which simulator? Run it with --device <name>; \`pls run simulators\` lists them." >&2
  exit 64
fi

# The exact name (any case) first, else the one name containing it; the newest runtime's copy wins.
wanted=${PLS_DEVICE:l}
match=$(print -r -- "$rows" | awk -F '\t' -v w="$wanted" 'tolower($1) == w')
[[ -z $match ]] && match=$(print -r -- "$rows" | awk -F '\t' -v w="$wanted" 'index(tolower($1), w)')
names=$(print -r -- "$match" | cut -f1 | grep . | sort -u)
if [[ -z $names ]]; then
  echo "No simulator called $PLS_DEVICE." >&2
  exit 1
fi
if (( $(print -r -- "$names" | wc -l) > 1 )); then
  echo "Several simulators match $PLS_DEVICE: $(print -r -- "$names" | paste -sd ',' - | sed 's/,/, /g')." >&2
  exit 1
fi
name=$names
udid=$(print -r -- "$match" | tail -1 | cut -f2)

case $PLS_ACTION in
  boot)
    xcrun simctl boot "$udid" 2>/dev/null
    open -a Simulator --args -CurrentDeviceUDID "$udid"
    echo "Booted $name." ;;
  shutdown)
    xcrun simctl shutdown "$udid" 2>/dev/null
    echo "Shut down $name." ;;
  erase)
    xcrun simctl shutdown "$udid" 2>/dev/null
    xcrun simctl erase "$udid" && echo "Erased $name." ;;
esac
