#!/bin/zsh
# @pls.name: Resize images
# @pls.description: Resize images in a folder to smaller pixel dimensions (width and height)
# @pls.param folder: path = ~/Desktop -- Folder containing the images
# @pls.param size: int(16...8000) = 1920 -- Longest side in pixels, when the request names one
# @pls.param format: enum(jpg|png|heic) = jpg -- Which images to resize - png for screenshots, jpg for photos, heic for iPhone photos
# @pls.example: resize the photos in ~/Pictures/trip to 1200 pixels
# @pls.example: scale screenshots down to 800px
# @pls.example: resize these images

# Writes resized copies to <folder>/resized, leaving the originals alone; never scales an image up.
setopt null_glob extended_glob
if [[ ! -d $PLS_FOLDER ]]; then
  echo "No folder at $PLS_FOLDER." >&2
  exit 1
fi
files=("$PLS_FOLDER"/*.(#i)(${PLS_FORMAT}|${PLS_FORMAT/jpg/jpeg}))
if (( ${#files} == 0 )); then
  echo "No .$PLS_FORMAT images in ${PLS_FOLDER/#$HOME/~}."
  exit 0
fi

out="$PLS_FOLDER/resized"
mkdir -p "$out" || exit 1
resized=0
for f in $files; do
  longest=$(sips -g pixelWidth -g pixelHeight "$f" | awk '/pixel/ {if ($2 > max) max = $2} END {print max}')
  if (( longest > PLS_SIZE )); then
    sips -Z "$PLS_SIZE" "$f" --out "$out/${f:t}" >/dev/null && (( resized++ ))
  else
    cp "$f" "$out/${f:t}"
  fi
done
echo "Resized $resized of ${#files} image(s) to at most $PLS_SIZE px into ${out/#$HOME/~}."
