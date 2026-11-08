#!/bin/zsh
# @pls.name: Switch Xcode
# @pls.description: Switch the active Xcode (xcode-select) between the installed versions, or list them and show which one is in use
# @pls.param action: enum(list|switch) = list -- switch only when the request asks to change the Xcode in use
# @pls.param xcode: string? -- The Xcode to switch to: a version number or beta, only when the request names one
# @pls.confirm: action=switch
# @pls.example: switch to Xcode beta
# @pls.example: use Xcode 26
# @pls.example: which Xcode am I using?
# @pls.example: list my Xcode versions

active=$(xcode-select -p 2>/dev/null)
active=${active%/Contents/Developer}

# "<path>\t<version>\t<build>" per installed Xcode.
xcodes=$(
  { print -l /Applications/Xcode*.app(N); mdfind "kMDItemCFBundleIdentifier == 'com.apple.dt.Xcode'"; } | sort -u |
    while read -r app; do
      plist=$app/Contents/version.plist
      [[ -f $plist ]] || continue
      printf '%s\t%s\t%s\n' "$app" "$(plutil -extract CFBundleShortVersionString raw -o - "$plist")" \
        "$(plutil -extract ProductBuildVersion raw -o - "$plist")"
    done
)
if [[ -z $xcodes ]]; then
  echo "No Xcode is installed in /Applications." >&2
  exit 1
fi

if [[ $PLS_ACTION == list || -z $PLS_XCODE ]]; then
  if [[ $PLS_ACTION == switch ]]; then
    echo "Which Xcode? Name a version, or beta:" >&2
  fi
  print -r -- "$xcodes" | while IFS=$'\t' read -r app version build; do
    printf '%s %-24s %s (%s)\n' "$([[ $app == $active ]] && echo '→' || echo ' ')" "${app:t}" "$version" "$build"
  done
  [[ $PLS_ACTION == switch ]] && exit 64
  exit 0
fi

# A beta has "beta" in its name or a build ending in a letter (26A5279d); otherwise the version starts with what was asked.
wanted=${PLS_XCODE:l}
wanted=${wanted#xcode}
wanted=${wanted# }
matches=$(print -r -- "$xcodes" | while IFS=$'\t' read -r app version build; do
  if [[ $wanted == beta ]]; then
    [[ ${app:t:l} == *beta* || $build == *[a-z] ]] && print -r -- "$app	$version	$build"
  elif [[ $version == $wanted || $version == $wanted.* ]]; then
    print -r -- "$app	$version	$build"
  fi
done)
count=$(print -r -- "$matches" | grep -c .)
if (( count == 0 )); then
  echo "No installed Xcode matches $PLS_XCODE. Installed: $(print -r -- "$xcodes" | cut -f2 | paste -sd ',' - | sed 's/,/, /g')." >&2
  exit 1
fi
if (( count > 1 )); then
  echo "Several Xcodes match $PLS_XCODE: $(print -r -- "$matches" | cut -f1 | xargs -I{} basename {} | paste -sd ',' - | sed 's/,/, /g'). Name the exact version." >&2
  exit 1
fi
IFS=$'\t' read -r app version build <<< "$matches"
if [[ $app == $active ]]; then
  echo "Already using Xcode $version ($build)."
  exit 0
fi
sudo xcode-select -s "$app/Contents/Developer" && echo "Now using Xcode $version ($build)."
