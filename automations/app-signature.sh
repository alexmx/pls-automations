#!/bin/zsh
# @pls.name: App signature
# @pls.description: Show how an app is code signed: who signed it, what kind of signature, whether it's valid and notarized, and its entitlements
# @pls.param app: string -- A path to an .app, .ipa or program, or the name of an installed app
# @pls.example: show the entitlements of ~/Desktop/MyApp.app
# @pls.example: is Slack signed and notarized?
# @pls.example: who signed this app ~/Downloads/Tool.app

work=$(mktemp -d -t pls-signature) || exit 1
trap 'rm -rf "$work"' EXIT

# A path as given, else an installed app by name, in any case but shown as it's spelled on disk.
setopt extended_glob
target=${~PLS_APP}
if [[ ! -e $target ]]; then
  name=${PLS_APP%.app}
  for folder in /Applications /System/Applications ~/Applications /Applications/Utilities; do
    found=($folder/(#i)$name.app(N))
    (( ${#found} )) && { target=$found[1]; break; }
  done
  [[ -e $target ]] || target=$(mdfind "kMDItemFSName == '$name.app'c && kMDItemContentType == com.apple.application-bundle" | head -1)
fi
if [[ -z $target || ! -e $target ]]; then
  echo "Couldn't find $PLS_APP: give its path, or the name of an installed app." >&2
  exit 1
fi
# An .ipa is a zip with the app in Payload/.
place=${target:h}
if [[ $target == *.ipa ]]; then
  place="in ${target:t}"
  unzip -q "$target" -d "$work" || exit 1
  target=$(print -l "$work"/Payload/*.app(N) | head -1)
  [[ -n $target ]] || { echo "$PLS_APP has no app inside." >&2; exit 1; }
  ios=1
fi

info=$(codesign -dvv "$target" 2>&1)
echo "${target:t}  $place"
if [[ $info == *"not signed at all"* ]]; then
  echo "  not signed"
  exit 0
fi
authority=$(print -r -- "$info" | sed -n 's/^Authority=//p' | head -1)
case $authority in
  "Developer ID Application:"*) kind="Developer ID" ;;
  "Apple Mac OS Application Signing") kind="Mac App Store" ;;
  "Apple Development:"* | "iPhone Developer:"* | "Mac Developer:"*) kind=development ;;
  "Apple Distribution:"* | "iPhone Distribution:"* | "3rd Party Mac Developer Application:"*) kind=distribution ;;
  "Software Signing" | "macOS Software Signing") kind="Apple (part of the system)" ;;
  "") kind="ad hoc (no identity)" ;;
  *) kind=$authority ;;
esac
[[ -n $authority ]] && echo "  signed by   $authority"
echo "  kind        $kind"
if verify=$(codesign --verify --deep --strict "$target" 2>&1); then
  echo "  signature   valid"
else
  echo "  signature   INVALID: $(print -r -- "$verify" | tail -1)"
fi
# Gatekeeper only assesses Mac apps.
if [[ -z $ios && $target == *.app ]]; then
  gatekeeper=$(spctl -a -vv "$target" 2>&1)
  source=$(print -r -- "$gatekeeper" | sed -n 's/^source=//p')
  if [[ $gatekeeper == *": accepted"* ]]; then
    echo "  gatekeeper  accepted ($source)"
  else
    echo "  gatekeeper  rejected${source:+ ($source)}"
  fi
  if [[ $source == "Notarized Developer ID" ]]; then
    xcrun stapler validate "$target" >/dev/null 2>&1 && ticket=stapled || ticket="not stapled (checked online)"
    echo "  notarized   yes, ticket $ticket"
  fi
fi

codesign -d --entitlements - --xml "$target" > "$work/entitlements.plist" 2>/dev/null
if [[ -s $work/entitlements.plist ]]; then
  echo "  entitlements"
  /usr/libexec/PlistBuddy -c "Print" "$work/entitlements.plist" | sed -e '1d' -e '$d' -e 's/^/  /'
else
  echo "  entitlements  none"
fi
