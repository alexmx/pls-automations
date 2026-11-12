#!/bin/zsh
# @pls.name: Prune merged git branches
# @pls.description: Delete the local git branches of a repo that are merged into its default branch, or whose remote branch is gone after a merge
# @pls.param folder: path = . -- The repo to clean up
# @pls.confirm: true
# @pls.preview: true
# @pls.example: clean up merged branches
# @pls.example: delete my old git branches
# @pls.example: prune the merged branches in ~/Projects/app

folder=${PLS_FOLDER:A}
if ! git -C "$folder" rev-parse --is-inside-work-tree &>/dev/null; then
  echo "${folder/#$HOME/~} isn't a git repo." >&2
  exit 1
fi
cd "$folder" || exit 1

# The default branch: origin's HEAD, or a local main or master. Merges are counted against origin's copy when there
# is one, since it's the one a merged pull request lands in.
base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
default=${base#origin/}
if [[ -z $default ]]; then
  for name in main master; do
    git show-ref --verify --quiet "refs/heads/$name" && { default=$name; break; }
  done
fi
if [[ -z $default ]]; then
  echo "Can't tell this repo's default branch; there's no origin/HEAD, main or master." >&2
  exit 1
fi
[[ -z $base ]] && base=$default

# Merged branches, plus those whose upstream is gone: a squash or rebase merge leaves no merge in history, only the
# deleted remote branch. Upstreams are as of the last fetch; this doesn't fetch.
current=$(git branch --show-current)
typeset -U branches
branches=(${(f)"$(git branch --merged "$base" --format='%(refname:short)')"})
branches+=(${(f)"$(git for-each-ref refs/heads --format='%(refname:short) %(upstream:track)' | sed -n 's/ \[gone\]$//p')"})
branches=(${branches:#($current|$default|main|master)})

repo=${folder/#$HOME/~}
if (( ${#branches} == 0 )); then
  echo "No merged branches to delete in $repo."
  exit 0
fi
if [[ -n $PLS_PREVIEW ]]; then
  echo "Would delete ${#branches} branch(es) in $repo: ${(j:, :)branches}."
  exit 0
fi
# -D, since a squash-merged branch isn't merged as far as git knows. git prints each one's last commit, to restore it.
git branch -D "${branches[@]}" || exit 1
echo "Deleted ${#branches} branch(es) in $repo."
