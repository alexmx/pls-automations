#!/bin/zsh
# @pls.description: Sort the files in a folder into subfolders by type: Images, Documents, Videos, Audio, Archives, Installers, Other
# @pls.param folder: path = ~/Downloads -- The folder to organize
# @pls.confirm: true
# @pls.preview: true
# @pls.example: organize my downloads
# @pls.example: sort the files on my desktop into folders
# @pls.example: tidy up ~/Downloads by type

folder=${PLS_FOLDER%/}
if [[ ! -d $folder ]]; then
  echo "No folder at $PLS_FOLDER." >&2
  exit 1
fi

category() {
  case ${1:e:l} in
    jpg|jpeg|png|gif|heic|webp|tif|tiff|bmp|svg|raw|cr2|nef) print Images ;;
    pdf|doc|docx|pages|txt|rtf|md|odt|xls|xlsx|numbers|csv|ppt|pptx|key|epub) print Documents ;;
    mov|mp4|m4v|avi|mkv|webm) print Videos ;;
    mp3|m4a|wav|aac|flac|aiff|ogg) print Audio ;;
    zip|tar|gz|tgz|bz2|xz|7z|rar) print Archives ;;
    dmg|pkg|iso|app) print Installers ;;
    *) print Other ;;
  esac
}

if [[ -n $PLS_PREVIEW ]]; then
  typeset -A counts
  for file in "$folder"/*(.N); do (( counts[$(category "$file")]++ )); done
  if (( ${#counts} == 0 )); then
    echo "No loose files in ${folder/#$HOME/~} to organize."
  else
    summary=()
    for kind in ${(ko)counts}; do summary+=("${counts[$kind]} to $kind"); done
    echo "Would move ${(j:, :)summary}."
  fi
  exit 0
fi

# Top-level files only (not folders or hidden files); a name clash gets " 2", " 3", …
typeset -A moved
for file in "$folder"/*(.N); do
  kind=$(category "$file")
  mkdir -p "$folder/$kind" || exit 1
  target="$folder/$kind/${file:t}"
  ext=${file:e}
  n=2
  while [[ -e $target ]]; do target="$folder/$kind/${file:t:r} $n${ext:+.$ext}"; (( n++ )); done
  mv -n "$file" "$target" && (( moved[$kind]++ ))
done

if (( ${#moved} == 0 )); then
  echo "No loose files in ${folder/#$HOME/~} to organize."
  exit 0
fi
summary=()
for kind in ${(ko)moved}; do summary+=("${moved[$kind]} $kind"); done
echo "Organized ${folder/#$HOME/~}: ${(j:, :)summary}."
