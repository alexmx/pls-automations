#!/bin/zsh
# @pls.description: Set the desktop picture to an image file
# @pls.param image: path -- The image file to use
# @pls.example: set my wallpaper to ~/Pictures/beach.jpg
# @pls.example: use this photo as my desktop background

if [[ ! -f $PLS_IMAGE ]]; then
  echo "No image at $PLS_IMAGE." >&2
  exit 1
fi
osascript -e 'on run argv
  tell application "System Events" to tell every desktop to set picture to (item 1 of argv)
end run' "$PLS_IMAGE" && echo "Wallpaper set to $PLS_IMAGE."
