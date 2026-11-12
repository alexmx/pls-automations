#!/bin/zsh
# @pls.name: Clean up git worktrees
# @pls.description: Remove a repo's extra git worktrees whose branch is merged into the default branch, or whose remote branch is gone after a merge, and delete those branches; worktrees with changes are kept
# @pls.param folder: path = . -- The repo, when the request names another one
# @pls.confirm: true
# @pls.preview: true
# @pls.example: clean up my worktrees
# @pls.example: remove merged worktrees
# @pls.example: delete the worktrees I'm done with in ~/Projects/app

folder=${PLS_FOLDER:A}
if ! git -C "$folder" rev-parse --is-inside-work-tree &>/dev/null; then
  echo "${folder/#$HOME/~} isn't a git repo." >&2
  exit 1
fi
cd "$folder" || exit 1
here=$(git rev-parse --show-toplevel)

# The default branch: origin's HEAD, or a local main or master; merges are counted against origin's copy.
base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
if [[ -z $base ]]; then
  for name in main master; do
    git show-ref --verify --quiet "refs/heads/$name" && { base=$name; break; }
  done
fi
if [[ -z $base ]]; then
  echo "Can't tell this repo's default branch; there's no origin/HEAD, main or master." >&2
  exit 1
fi

# Done branches: merged, or with their upstream gone after a squash or rebase merge (as of the last fetch).
typeset -U done_branches
done_branches=(${(f)"$(git branch --merged "$base" --format='%(refname:short)')"})
done_branches+=(${(f)"$(git for-each-ref refs/heads --format='%(refname:short) %(upstream:track)' | sed -n 's/ \[gone\]$//p')"})

# "<path>\t<branch>" per worktree but the main one (listed first); detached and locked ones are left alone.
worktrees=$(git worktree list --porcelain | awk '
  /^worktree / { path = substr($0, 10); branch = ""; locked = 0 }
  /^branch refs\/heads\// { branch = substr($0, 19) }
  /^locked/ { locked = 1 }
  /^$/ { if (n++ && branch != "" && !locked) print path "\t" branch; branch = "" }
  END { if (n && branch != "" && !locked) print path "\t" branch }')

remove=() removed_branches=() kept=()
while IFS=$'\t' read -r wt branch; do
  [[ -z $wt || $wt == $here || -z ${done_branches[(r)$branch]} ]] && continue
  if [[ -d $wt && -n $(git -C "$wt" status --porcelain 2>/dev/null) ]]; then
    kept+=("$branch")
  else
    remove+=("$wt") removed_branches+=("$branch")
  fi
done <<< "$worktrees"

main=$(git worktree list --porcelain | sed -n '1s/^worktree //p')
repo=${main/#$HOME/~}
note=${kept:+ Kept ${(j:, :)kept}: uncommitted or untracked changes.}
if (( ${#remove} == 0 )); then
  echo "No worktrees to remove in $repo.$note"
  exit 0
fi
if [[ -n $PLS_PREVIEW ]]; then
  echo "Would remove ${#remove} worktree(s) and their branches in $repo: ${(j:, :)removed_branches}.$note"
  exit 0
fi
for wt in "${remove[@]}"; do
  # A worktree whose folder is already gone is dropped by the prune below.
  [[ -d $wt ]] && { git worktree remove "$wt" || exit 1; }
done
git worktree prune
# -D, since a squash-merged branch isn't merged as far as git knows. git prints each one's last commit, to restore it.
git branch -D "${removed_branches[@]}" || exit 1
echo "Removed ${#remove} worktree(s) and their branches in $repo: ${(j:, :)removed_branches}.$note"
