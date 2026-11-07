#!/bin/zsh
# @pls.description: Show or hide hidden files (dotfiles) in Finder
# @pls.param mode: enum(show|hide|toggle) = toggle -- Whether Finder shows hidden files
# @pls.example: show hidden files
# @pls.example: hide dotfiles in Finder
# @pls.example: I can't see my .zshrc in Finder

current=$(defaults read com.apple.finder AppleShowAllFiles 2>/dev/null)
case $PLS_MODE in
  show) show=true ;;
  hide) show=false ;;
  toggle) [[ $current == (1|true|TRUE|YES|yes) ]] && show=false || show=true ;;
esac

defaults write com.apple.finder AppleShowAllFiles -bool $show
killall Finder
[[ $show == true ]] && echo "Hidden files are now shown." || echo "Hidden files are now hidden."
