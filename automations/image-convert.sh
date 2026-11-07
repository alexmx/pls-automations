#!/bin/zsh
# @pls.name: Convert images
# @pls.description: Convert images in a folder to another file format
# @pls.param to: enum(jpg|png|heic|pdf|tiff) -- The format to convert to
# @pls.param folder: path = ~/Desktop -- Folder containing the images
# @pls.param from: enum(any|heic|png|jpg|tiff) = any -- Which images to convert - heic for iPhone photos, png for screenshots; any for all
# @pls.example: convert my iPhone photos to jpg
# @pls.example: turn the heic files in ~/Downloads into jpgs
# @pls.example: make pdfs of the images on my desktop
# @pls.example: convert these screenshots to jpg

# Writes converted copies to <folder>/converted, leaving the originals alone.
setopt null_glob extended_glob
if [[ ! -d $PLS_FOLDER ]]; then
  echo "No folder at $PLS_FOLDER." >&2
  exit 1
fi
case $PLS_FROM in
  any) pattern='(jpg|jpeg|png|heic|tif|tiff|gif|bmp)' ;;
  jpg) pattern='(jpg|jpeg)' ;;
  tiff) pattern='(tif|tiff)' ;;
  *) pattern=$PLS_FROM ;;
esac
files=("$PLS_FOLDER"/*.(#i)${~pattern})
# Already in the target format: nothing to do.
case $PLS_TO in
  jpg) files=(${files:#*.(#i)(jpg|jpeg)}) ;;
  tiff) files=(${files:#*.(#i)(tif|tiff)}) ;;
  *) files=(${files:#*.(#i)$PLS_TO}) ;;
esac
if (( ${#files} == 0 )); then
  echo "No images to convert in ${PLS_FOLDER/#$HOME/~}."
  exit 0
fi

format=${PLS_TO/jpg/jpeg}
out="$PLS_FOLDER/converted"
mkdir -p "$out" || exit 1
converted=0
for f in $files; do
  sips -s format "$format" "$f" --out "$out/${f:t:r}.$PLS_TO" >/dev/null && (( converted++ ))
done
echo "Converted $converted image(s) to $PLS_TO into ${out/#$HOME/~}."
