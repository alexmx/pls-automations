#!/bin/zsh
# @pls.description: Update Homebrew, upgrade all installed packages, and clean up old versions and unused dependencies
# @pls.example: update brew
# @pls.example: upgrade my homebrew packages
# @pls.example: brew update and upgrade

if ! command -v brew >/dev/null; then
  echo "Homebrew isn't installed; see https://brew.sh." >&2
  exit 1
fi

brew update && brew upgrade && brew cleanup && brew autoremove && echo "Homebrew is up to date."
