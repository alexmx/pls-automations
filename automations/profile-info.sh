#!/bin/zsh
# @pls.name: Provisioning profile info
# @pls.description: Show what's in an iOS or macOS provisioning profile (app id, team, type, expiry, devices, entitlements), or list the installed profiles and which have expired
# @pls.param path: path? -- A .mobileprovision or .provisionprofile file, only when the request names one
# @pls.example: what's in this provisioning profile ~/Downloads/App.mobileprovision
# @pls.example: which of my provisioning profiles are expired?
# @pls.example: list my provisioning profiles

decoded=$(mktemp -t pls-profile) || exit 1
trap 'rm -f "$decoded"' EXIT

# Reads one profile into $decoded; fails if it isn't one.
decode() {
  security cms -D -i "$1" > "$decoded" 2>/dev/null && plutil -lint -s "$decoded" >/dev/null 2>&1
}
field() {
  plutil -extract "$1" raw -o - "$decoded" 2>/dev/null
}
# iOS profiles keep it as application-identifier, macOS ones as com.apple.application-identifier.
app_id() {
  field Entitlements.application-identifier || field 'Entitlements.com\.apple\.application-identifier'
}
kind() {
  if [[ $(field ProvisionsAllDevices) == true ]]; then echo enterprise
  elif [[ -z $(field ProvisionedDevices) ]]; then echo "App Store"
  elif [[ $(field Entitlements.get-task-allow) == true ]]; then echo development
  else echo "ad hoc"
  fi
}
# "expires 3 Mar 2027 (in 115 days)" or "EXPIRED 2 days ago".
expiry() {
  local expires=$(date -j -u -f "%Y-%m-%dT%H:%M:%SZ" "$(field ExpirationDate)" +%s 2>/dev/null)
  local days=$(( (expires - $(date +%s)) / 86400 ))
  if (( expires < $(date +%s) )); then
    echo "EXPIRED $(( -days )) days ago"
  else
    echo "expires $(date -j -r "$expires" '+%-d %b %Y') (in $days days)"
  fi
}

if [[ -n $PLS_PATH ]]; then
  if ! decode "$PLS_PATH"; then
    echo "$PLS_PATH isn't a provisioning profile." >&2
    exit 1
  fi
  echo "$(field Name)"
  echo "  team      $(field TeamName) ($(field 'TeamIdentifier.0'))"
  echo "  app id    $(app_id)"
  echo "  type      $(kind)"
  echo "  validity  $(expiry)"
  devices=$(field ProvisionedDevices)
  [[ -n $devices ]] && echo "  devices   $devices"
  echo "  entitlements"
  /usr/libexec/PlistBuddy -c "Print :Entitlements" "$decoded" | sed -e '1d' -e '$d' -e 's/^/  /'
  exit 0
fi

# Every installed profile, soonest to expire (or longest expired) first.
profiles=(~/Library/Developer/Xcode/UserData/Provisioning\ Profiles/*(N) ~/Library/MobileDevice/Provisioning\ Profiles/*(N))
if (( ${#profiles} == 0 )); then
  echo "No provisioning profiles are installed."
  exit 0
fi
for profile in $profiles; do
  decode "$profile" || continue
  printf '%s\t%s\t%s\t%s\t%s\n' "$(field ExpirationDate)" "$(field Name)" \
    "$(app_id)" "$(kind)" "$(expiry)"
done | sort | cut -f2- | column -t -s $'\t'
