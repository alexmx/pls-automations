#!/bin/zsh
# @pls.description: Change the folder new screenshots are saved in, or show where they go
# @pls.param folder: path? -- Folder to save new screenshots in
# @pls.example: save screenshots to ~/Pictures/Screenshots
# @pls.example: where do my screenshots go?
# @pls.example: put my screenshots in ~/Documents

if [[ -n $PLS_FOLDER ]]; then
  mkdir -p "$PLS_FOLDER" || exit 1
  defaults write com.apple.screencapture location "$PLS_FOLDER"
  killall SystemUIServer
  echo "Screenshots now go to ${PLS_FOLDER/#$HOME/~}."
else
  folder=$(defaults read com.apple.screencapture location 2>/dev/null || echo ~/Desktop)
  echo "Screenshots go to ${folder/#$HOME/~}."
fi
