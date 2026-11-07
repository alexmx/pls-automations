#!/bin/zsh
# @pls.description: Speak or announce text out loud with the Mac's text-to-speech voice
# @pls.param text: string -- The words to speak, without the instruction around them
# @pls.param voice: string? -- The system voice to use, only when the request names one
# @pls.example: say hello world
# @pls.example: read build finished out loud
# @pls.example: speak the word done
# @pls.example: say good morning in Samantha's voice

if [[ -n $PLS_VOICE ]]; then
  # `say -v '?'` lists "<name>  <locale>  # <sample>"; names can have spaces.
  voices=("${(@f)$(say -v '?' | sed -E 's/ +[a-z]{2,3}_[A-Za-z0-9]+ +#.*$//')}")
  if (( ! ${voices[(Ie)$PLS_VOICE]} )); then
    english=$(say -v '?' | awk '/ en_/' | sed -E 's/ +[a-z]{2,3}_[A-Za-z0-9]+ +#.*$//' | head -12 | paste -sd ',' - | sed 's/,/, /g')
    echo "No voice named $PLS_VOICE. Some English voices: $english" >&2
    exit 1
  fi
  say -v "$PLS_VOICE" -- "$PLS_TEXT"
else
  say -- "$PLS_TEXT"
fi
