-- @pls.name: Hide other apps
-- @pls.description: Hide every app except the one in front, to clear the screen
-- @pls.example: hide everything else
-- @pls.example: clear my screen
-- @pls.example: hide all other windows

on run argv
	tell application "System Events"
		set others to every application process whose visible is true and frontmost is false and background only is false
		set hidden to count of others
		repeat with p in others
			set visible of p to false
		end repeat
	end tell
	return "Hid " & hidden & " app(s)."
end run
