#!/bin/zsh
# @pls.name: Open URL in simulator
# @pls.description: Open a link or deep link (a custom URL scheme) in the running iOS simulator, to test how an app handles it
# @pls.param url: string -- The link to open: a web address or an app's deep link
# @pls.example: open myapp://settings in the simulator
# @pls.example: test the deep link myapp://profile/42 on the simulator
# @pls.example: open apple.com in the iPhone simulator

device=$(xcrun simctl list devices booted | sed -nE 's/^ +(.*) \([0-9A-F-]{36}\) \(Booted\) *$/\1/p' | head -1)
if [[ -z $device ]]; then
  echo "No simulator is running; boot one with \`pls run simulators boot --device <name>\`." >&2
  exit 1
fi

# A bare domain gets https://, as a browser's address bar would.
url=$PLS_URL
[[ $url != *://* && $url != *:* ]] && url="https://$url"

if ! error=$(xcrun simctl openurl booted "$url" 2>&1); then
  # LaunchServices' "no app for this scheme".
  if [[ $error == *"LSApplicationWorkspaceErrorDomain, code=115"* ]]; then
    echo "No app in $device handles ${url%%:*}:// links." >&2
  else
    print -r -- "$error" >&2
  fi
  exit 1
fi
echo "Opened $url in $device."
