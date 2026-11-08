#!/bin/zsh
# @pls.name: Ghostty workspace
# @pls.description: Open a folder in a new Ghostty tab split into three panes: a shell, lazygit and another shell
# @pls.param folder: path = . -- The project folder to open
# @pls.example: open a dev workspace for ~/Projects/quick
# @pls.example: set up a ghostty workspace here
# @pls.example: open ~/Developer/app in a three pane ghostty tab

folder=${PLS_FOLDER:A}
if [[ ! -d $folder ]]; then
  echo "No folder at $PLS_FOLDER." >&2
  exit 1
fi

# lazygit for a repo, or git's own short status where lazygit isn't installed.
git_pane=""
if git -C "$folder" rev-parse --is-inside-work-tree &>/dev/null; then
  if (( $+commands[lazygit] )); then git_pane="lazygit"; else git_pane="git status -sb"; fi
fi

# Left: a shell. Top right: lazygit, or a shell outside a repo. Bottom right: a shell. Commands are typed into each
# pane's shell, so quitting lazygit leaves a shell there.
output=$(osascript - "$folder" "$git_pane" 2>&1 <<'APPLESCRIPT'
on run argv
	set projectDir to item 1 of argv
	set gitCommand to item 2 of argv
	tell application "Ghostty"
		activate
		set cfg to new surface configuration
		set initial working directory of cfg to projectDir
		-- A tab in the front window, or a window when none is open.
		if (count of windows) > 0 then
			set newTab to new tab in front window with configuration cfg
		else
			set newTab to selected tab of (new window with configuration cfg)
		end if
		set mainPane to focused terminal of newTab
		set topRight to split mainPane direction right with configuration cfg
		split topRight direction down with configuration cfg
		if gitCommand is not "" then input text gitCommand & linefeed to topRight
		focus mainPane
	end tell
end run
APPLESCRIPT
)
if (( $? != 0 )); then
  if [[ $output == *"-1708"* || $output == *"-2741"* || $output == *"-1728"* ]]; then
    echo "Ghostty can't be scripted here; it needs Ghostty 1.3 or later." >&2
  else
    print -r -- "$output" >&2
  fi
  exit 1
fi
echo "Opened ${folder/#$HOME/~} in Ghostty${git_pane:+, with $git_pane}."
