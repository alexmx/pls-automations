#!/bin/zsh
# @pls.name: Ghostty workspace
# @pls.description: Split the current Ghostty pane into a dev workspace: this shell on the left, lazygit top right and a smaller shell bottom right
# @pls.param folder: path = . -- The project folder the workspace opens in
# @pls.example: new dev workspace
# @pls.example: set up a ghostty workspace here
# @pls.example: open a dev workspace for ~/Projects/quick
# @pls.example: split this pane into three for ~/Developer/app

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

# Left: the pane pls runs in. Top right: lazygit, or a shell outside a repo. Bottom right: a shell a third the height
# of the one above. Ghostty resizes splits only by pixels, so the divider is moved by a measured step, then by as many
# rows as are left, counted from the panes' terminal sizes. Commands are typed into each pane's shell, so quitting
# lazygit leaves a shell there. For another folder, a cd is typed into the current pane too; its shell runs it once pls
# exits.
cd_command=""
[[ $folder != ${PWD:A} ]] && cd_command="cd ${(q)folder}"
output=$(osascript - "$folder" "$git_pane" "$cd_command" 2>&1 <<'APPLESCRIPT'
on rowsOf(ttyPath)
	return (word 1 of (do shell script "stty -f " & quoted form of ttyPath & " size")) as integer
end rowsOf

on run argv
	set projectDir to item 1 of argv
	set gitCommand to item 2 of argv
	set cdCommand to item 3 of argv
	tell application "Ghostty"
		if (count of windows) is 0 then error "Ghostty has no window open to split."
		set mainPane to focused terminal of selected tab of front window
		set cfg to new surface configuration
		set initial working directory of cfg to projectDir
		set topRight to split mainPane direction right with configuration cfg
		set bottomRight to split topRight direction down with configuration cfg
		if gitCommand is not "" then input text gitCommand & linefeed to topRight
		if cdCommand is not "" then input text cdCommand & linefeed to mainPane
		focus mainPane
		delay 0.3
		set topTTY to tty of topRight
		set bottomTTY to tty of bottomRight
	end tell
	-- Moving the divider down shrinks the bottom pane; aim for a quarter of the column.
	set targetRows to (round (((my rowsOf(topTTY)) + (my rowsOf(bottomTTY))) / 4)) as integer
	set startRows to my rowsOf(bottomTTY)
	if startRows > targetRows then
		tell application "Ghostty" to perform action "resize_split:down,50" on bottomRight
		delay 0.2
		set movedRows to startRows - (my rowsOf(bottomTTY))
		set leftRows to startRows - movedRows - targetRows
		if movedRows > 0 and leftRows > 0 then
			set step to (round (leftRows * 50 / movedRows)) as integer
			tell application "Ghostty" to perform action ("resize_split:down," & step) on bottomRight
		end if
	end if
end run
APPLESCRIPT
)
if (( $? != 0 )); then
  if [[ $output == *"no window open"* ]]; then
    echo "Ghostty has no window open to split." >&2
  elif [[ $output == *"-1708"* || $output == *"-2741"* || $output == *"-1728"* ]]; then
    echo "Ghostty can't be scripted here; it needs Ghostty 1.3 or later." >&2
  else
    print -r -- "$output" >&2
  fi
  exit 1
fi
echo "Split into a workspace for ${folder/#$HOME/~}${git_pane:+, with $git_pane}."
