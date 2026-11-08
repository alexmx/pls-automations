#!/bin/zsh
# @pls.name: Push notification in simulator
# @pls.description: Send a test push notification to an app in the running iOS simulator, by its bundle id
# @pls.param bundle_id: string -- The app's bundle id, which identifies it
# @pls.param body: string = Test notification -- The notification's text
# @pls.param title: string? -- A title above the text, only when the request gives one
# @pls.param badge: int(0...999) = 0 -- The number on the app's icon; 0 leaves it unchanged
# @pls.example: send a test push to com.me.app saying Hello
# @pls.example: push notification to com.acme.shop with title Sale and text 50% off
# @pls.example: simulate a push for com.me.app

device=$(xcrun simctl list devices booted | sed -nE 's/^ +(.*) \([0-9A-F-]{36}\) \(Booted\) *$/\1/p' | head -1)
if [[ -z $device ]]; then
  echo "No simulator is running; boot one with \`pls run simulators boot --device <name>\`." >&2
  exit 1
fi
if ! xcrun simctl get_app_container booted "$PLS_BUNDLE_ID" >/dev/null 2>&1; then
  echo "$PLS_BUNDLE_ID isn't installed in $device." >&2
  exit 1
fi

# plutil writes the payload (a plist, then JSON), so quotes and emoji in the text can't break it.
payload=$(mktemp -t pls-push) || exit 1
trap 'rm -f "$payload"' EXIT
plutil -create xml1 "$payload"
plutil -insert aps -dictionary "$payload"
plutil -insert aps.alert -dictionary "$payload"
plutil -insert aps.alert.body -string "$PLS_BODY" "$payload"
[[ -n $PLS_TITLE ]] && plutil -insert aps.alert.title -string "$PLS_TITLE" "$payload"
plutil -insert aps.sound -string default "$payload"
(( PLS_BADGE > 0 )) && plutil -insert aps.badge -integer "$PLS_BADGE" "$payload"
plutil -convert json "$payload"

xcrun simctl push booted "$PLS_BUNDLE_ID" "$payload" >/dev/null || exit 1
echo "Sent “$PLS_BODY” to $PLS_BUNDLE_ID in $device."
