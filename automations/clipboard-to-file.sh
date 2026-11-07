#!/bin/zsh
# @pls.description: Save the copied text to a file
# @pls.param file: path = ~/Desktop/clipboard.txt -- The file to save it in, when the request names one
# @pls.example: save the clipboard to a file
# @pls.example: paste what I copied into ~/notes/snippet.md
# @pls.example: dump the clipboard to my desktop

# Most apps copy a plain version too; when only rich text was copied, convert it.
text=$(pbpaste; print -n x)
text=${text%x}
if [[ -z $text ]]; then
  text=$(osascript -e 'the clipboard as «class RTF »' 2>/dev/null | sed -E 's/^«data RTF ([0-9A-F]*)»$/\1/' | xxd -r -p \
    | textutil -stdin -stdout -format rtf -convert txt 2>/dev/null; print -n x)
  text=${text%x}
fi
if [[ -z $text ]]; then
  echo "The clipboard has no text." >&2
  exit 1
fi

# Never overwrites: "clipboard.txt" becomes "clipboard 2.txt", …
file=$PLS_FILE
ext=${file:e}
n=2
while [[ -e $file ]]; do file="${PLS_FILE:r} $n${ext:+.$ext}"; (( n++ )); done
mkdir -p "${file:h}" || exit 1
print -rn -- "$text" > "$file" || exit 1
echo "Saved ${#text} characters to ${file/#$HOME/~}."
