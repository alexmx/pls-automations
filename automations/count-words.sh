#!/bin/zsh
# @pls.description: Count the words, characters and lines in the copied text
# @pls.example: how many words did I copy?
# @pls.example: word count of the clipboard
# @pls.example: count the characters in this

# Most apps copy a plain version too; when only rich text was copied, convert it.
text=$(pbpaste; print -n x)
text=${text%x}
if [[ -z $text ]]; then
  text=$(osascript -e 'the clipboard as «class RTF »' 2>/dev/null | sed -E 's/^«data RTF ([0-9A-F]*)»$/\1/' | xxd -r -p \
    | textutil -stdin -stdout -format rtf -convert txt 2>/dev/null; print -n x)
  text=${text%x}
fi
if [[ -z $text ]]; then
  echo "The clipboard has no text."
  exit 0
fi

export LC_ALL=en_US.UTF-8
words=$(print -rn -- "$text" | wc -w | tr -d ' ')
characters=${#text}
lines=$(print -rn -- "$text" | awk 'END {print NR}')
# "1 line", "2 lines".
count() { printf "%'d %s" "$1" "$2"; (( $1 == 1 )) || printf s; }
echo "$(count $words word) · $(count $characters character) · $(count $lines line)"
