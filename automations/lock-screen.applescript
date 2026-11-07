-- @pls.description: Lock the Mac now, so it needs your password to get back in
-- @pls.example: lock my mac
-- @pls.example: lock the screen
-- @pls.example: I'm leaving, lock it

-- Presses Control-Command-Q, the system's lock shortcut. Needs Accessibility permission for the terminal.
on run argv
	tell application "System Events" to keystroke "q" using {control down, command down}
	return "Locked."
end run
