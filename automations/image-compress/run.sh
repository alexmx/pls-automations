#!/bin/zsh
# Writes compressed copies to <folder>/compressed, leaving the originals alone.
setopt null_glob extended_glob
out="$PLS_FOLDER/compressed"
mkdir -p "$out"
files=("$PLS_FOLDER"/*.(#i)$PLS_FORMAT)
for f in $files; do
  if [[ $PLS_FORMAT == png ]]; then
    # PNG is lossless, so quality does nothing to it; a JPEG copy is what makes a screenshot small.
    sips -s format jpeg -s formatOptions "$PLS_QUALITY" "$f" --out "$out/${f:t:r}.jpg" >/dev/null
  else
    sips -s formatOptions "$PLS_QUALITY" "$f" --out "$out/${f:t}" >/dev/null
  fi
done
echo "Compressed ${#files} file(s) into $out"
