#!/bin/zsh
# @pls.name: Clean up Xcode
# @pls.description: Free the disk space Xcode piles up: DerivedData (also fixes stale builds), device support files, old simulators whose iOS version is no longer installed and simulator caches, and Swift package caches; archives are kept
# @pls.param what: enum(all|derived-data|device-support|simulators|package-caches) = all -- What to clean; all unless the request names one
# @pls.confirm: true
# @pls.preview: true
# @pls.example: Xcode is hogging space, clean it up
# @pls.example: clear derived data
# @pls.example: Xcode is acting weird, nuke derived data
# @pls.example: delete old device support files
# @pls.example: clear the Swift package caches
# @pls.example: clean up old simulators to free space

developer=~/Library/Developer
labels=() folders=() kilobytes=()
wants() { [[ $PLS_WHAT == all || $PLS_WHAT == $1 ]] }
# Adds a folder whose contents can go, if they take a megabyte or more.
add() {
  local items=("$2"/*(DN))
  (( ${#items} )) || return
  local kb=$(du -sk "$2" | cut -f1)
  (( kb >= 1024 )) || return
  labels+=("$1") folders+=("$2") kilobytes+=($kb)
}
size() {
  awk -v kb="$1" 'BEGIN { if (kb >= 1048576) printf "%.1f GB", kb / 1048576; else printf "%.0f MB", kb / 1024 }'
}

wants derived-data && add DerivedData "$developer/Xcode/DerivedData"
if wants device-support; then
  for folder in "$developer"/Xcode/*DeviceSupport(N/); do add "${folder:t}" "$folder"; done
fi
if wants simulators; then
  add "Simulator caches" "$developer/CoreSimulator/Caches"
  # Simulators whose runtime is gone; simctl deletes them, their data folders show the size.
  unavailable=($(xcrun simctl list devices unavailable 2>/dev/null | sed -nE 's/.*\(([0-9A-F-]{36})\).*unavailable.*/\1/p'))
  if (( ${#unavailable} )); then
    labels+=("${#unavailable} unavailable simulator(s)") folders+=(simctl)
    kilobytes+=($(du -sk "${unavailable[@]/#/$developer/CoreSimulator/Devices/}" 2>/dev/null | awk '{ s += $1 } END { print s + 0 }'))
  fi
fi
wants package-caches && add "SwiftPM caches" ~/Library/Caches/org.swift.swiftpm

if (( ${#labels} == 0 )); then
  echo "Nothing to clean up."
  exit 0
fi
total=0 parts=()
for i in {1..${#labels}}; do
  total=$(( total + kilobytes[i] ))
  parts+=("${labels[i]} $(size $kilobytes[i])")
done
summary="$(size $total): ${(j:, :)parts}"

if [[ -n $PLS_PREVIEW ]]; then
  echo "Would free $summary."
  exit 0
fi
for folder in "${folders[@]}"; do
  if [[ $folder == simctl ]]; then
    xcrun simctl delete unavailable || exit 1
  else
    rm -rf -- "$folder"/*(DN) || exit 1
  fi
done
echo "Freed $summary."
wants derived-data && pgrep -xq Xcode && echo "Xcode is open: the next build starts from scratch."
exit 0
