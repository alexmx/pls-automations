#!/bin/zsh
# @pls.name: Git worktree
# @pls.description: Start work on a git branch in its own worktree, a folder next to the repo, and open it in a new Ghostty tab; a new branch starts from the default branch
# @pls.param branch: string -- The branch to work on, new or existing
# @pls.param folder: path = . -- The repo, when the request names another one
# @pls.example: new worktree for fix-login
# @pls.example: work on feature/search in a worktree
# @pls.example: check out release-2.0 in a separate folder

branch=$PLS_BRANCH
folder=${PLS_FOLDER:A}
if ! git -C "$folder" rev-parse --is-inside-work-tree &>/dev/null; then
  echo "${folder/#$HOME/~} isn't a git repo." >&2
  exit 1
fi
if ! git check-ref-format --branch "$branch" &>/dev/null; then
  echo "\"$branch\" isn't a valid branch name." >&2
  exit 1
fi
cd "$folder" || exit 1

# The main worktree, even when asked from another one: worktrees go next to it, as <repo>-<branch>.
main=$(git worktree list --porcelain | sed -n '1s/^worktree //p')
target="${main:h}/${main:t}-${branch//\//-}"

# A worktree that already has the branch is opened as it is.
existing=$(git worktree list --porcelain | awk -v ref="refs/heads/$branch" '
  /^worktree / { path = substr($0, 10) } $0 == "branch " ref { print path; exit }')
if [[ -n $existing ]]; then
  target=$existing
  summary="${branch} is already checked out in ${target/#$HOME/~}"
elif [[ -e $target ]]; then
  echo "${target/#$HOME/~} already exists and isn't a worktree for $branch." >&2
  exit 1
elif git show-ref --verify --quiet "refs/heads/$branch" || git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
  # A local branch, or one only on origin: git makes the local branch tracking it.
  git worktree add --quiet "$target" "$branch" || exit 1
  summary="Checked out $branch in ${target/#$HOME/~}"
else
  # A new branch from the default one: origin's when there is one, without tracking it, so a push makes its own.
  base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
  if [[ -z $base ]]; then
    for name in main master; do
      git show-ref --verify --quiet "refs/heads/$name" && { base=$name; break; }
    done
  fi
  [[ -z $base ]] && base=HEAD
  git worktree add --quiet --no-track -b "$branch" "$target" "$base" || exit 1
  summary="Created $branch from $base in ${target/#$HOME/~}"
fi

if [[ $TERM_PROGRAM != ghostty ]]; then
  echo "$summary."
  exit 0
fi
output=$(osascript - "$target" 2>&1 <<'APPLESCRIPT'
on run argv
	tell application "Ghostty"
		activate
		set cfg to new surface configuration
		set initial working directory of cfg to item 1 of argv
		if (count of windows) > 0 then
			new tab in front window with configuration cfg
		else
			new window with configuration cfg
		end if
	end tell
end run
APPLESCRIPT
)
if (( $? != 0 )); then
  echo "$summary, but Ghostty couldn't open a tab there: ${output}" >&2
  exit 1
fi
echo "$summary, in a new Ghostty tab."
