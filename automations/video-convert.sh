#!/bin/zsh
# @pls.name: Convert video
# @pls.description: Shrink or convert a video file (.mov, .mp4) to a smaller size or another format, keeping the original
# @pls.param file: path -- The video file
# @pls.param quality: enum(small|medium|high) = medium -- small (about 320p) for email or chat, medium for 720p, high keeps 1080p
# @pls.param format: enum(mp4|mov) = mp4 -- The output file type
# @pls.example: make this video smaller: ~/Movies/demo.mov
# @pls.example: convert screen-recording.mov to mp4
# @pls.example: shrink ~/Desktop/clip.mov so I can email it

if [[ ! -f $PLS_FILE ]]; then
  echo "No video at $PLS_FILE." >&2
  exit 1
fi
case $PLS_QUALITY in
  small) preset=PresetMediumQuality ;;
  medium) preset=Preset1280x720 ;;
  high) preset=PresetHEVC1920x1080 ;;
esac

out="${PLS_FILE:r}-converted.$PLS_FORMAT"
# avconvert reports even success on stderr; show what it says only when it fails.
if ! log=$(avconvert --source "$PLS_FILE" --preset "$preset" --output "$out" --replace 2>&1); then
  print -r -- "$log" >&2
  exit 1
fi
human() { awk -v b="$1" 'BEGIN { if (b >= 1048576) printf "%.1f MB", b / 1048576; else printf "%.0f KB", b / 1024 }'; }
before=$(stat -f %z "$PLS_FILE")
after=$(stat -f %z "$out")
echo "Saved ${out/#$HOME/~} ($(human $before) → $(human $after))."
(( after > before )) && echo "It's larger than the original, which was already compressed; try quality small."
