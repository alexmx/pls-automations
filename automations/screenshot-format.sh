#!/bin/zsh
# @pls.description: Change the setting for which file format future screenshots are saved in (existing files stay as they are)
# @pls.param format: enum(png|jpg|pdf|heic) -- File format for new screenshots
# @pls.example: make screenshots jpg
# @pls.example: save screenshots as pdf from now on

defaults write com.apple.screencapture type "$PLS_FORMAT"
killall SystemUIServer
echo "Screenshots are now saved as $PLS_FORMAT."
