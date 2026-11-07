#!/bin/zsh
# @pls.description: Remove formatting from the copied text, so it pastes as plain text
# @pls.example: make the clipboard plain text
# @pls.example: strip formatting from what I copied
# @pls.example: paste without formatting

# Most apps copy a plain version too; when only rich text was copied, convert it.
text=$(pbpaste; print -n x)
text=${text%x}
if [[ -z $text ]]; then
  # AppleScript hands the rich text over as «data RTF 7B5C…»: hex to bytes, then to plain text.
  text=$(osascript -e 'the clipboard as «class RTF »' 2>/dev/null | sed -E 's/^«data RTF ([0-9A-F]*)»$/\1/' | xxd -r -p \
    | textutil -stdin -stdout -format rtf -convert txt 2>/dev/null; print -n x)
  text=${text%x}
fi
if [[ -z $text ]]; then
  echo "The clipboard has no text."
  exit 0
fi
print -rn -- "$text" | pbcopy
echo "The clipboard is now plain text (${#text} characters)."
