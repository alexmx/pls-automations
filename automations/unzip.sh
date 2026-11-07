#!/bin/zsh
# @pls.name: Unzip
# @pls.description: Extract a .zip archive next to it
# @pls.param archive: path -- The .zip file
# @pls.example: unzip ~/Downloads/fonts.zip
# @pls.example: extract this archive
# @pls.example: open the zip in my downloads

if [[ ! -f $PLS_ARCHIVE ]]; then
  echo "No archive at $PLS_ARCHIVE." >&2
  exit 1
fi

# A free name next to the archive: "fonts", else "fonts 2", …
unique() {
  local candidate=$1 n=2
  while [[ -e $candidate ]]; do candidate="$1 $n"; (( n++ )); done
  print -r -- "$candidate"
}

# Like Finder: extract into a scratch folder, then keep a single top-level item as is, or wrap several in a folder
# named after the archive.
parent=${PLS_ARCHIVE:h}
scratch=$(mktemp -d "$parent/.pls-unzip-XXXXXX") || exit 1
trap 'rm -rf "$scratch"' EXIT
ditto -x -k "$PLS_ARCHIVE" "$scratch" || exit 1
rm -rf "$scratch/__MACOSX"

entries=("$scratch"/*(DN))
if (( ${#entries} == 1 )); then
  out=$(unique "$parent/${entries[1]:t}")
  mv "${entries[1]}" "$out"
else
  out=$(unique "${PLS_ARCHIVE:r}")
  mkdir "$out" && mv "$scratch"/*(DN) "$out"/
fi
count=$(find "$out" -type f | wc -l | tr -d ' ')
echo "Extracted $count file(s) to ${out/#$HOME/~}."
