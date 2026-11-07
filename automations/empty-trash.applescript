-- @pls.description: Empty the Trash, permanently deleting what's in it
-- @pls.confirm: true
-- @pls.preview: true
-- @pls.example: empty the trash
-- @pls.example: take out the trash
-- @pls.example: clear the bin

on run argv
	tell application "Finder"
		set itemCount to count of items of trash
		if itemCount is 0 then return "The Trash is already empty."
		if (system attribute "PLS_PREVIEW") is not "" then return "Would permanently delete " & itemCount & " item(s) in the Trash."
		empty trash
	end tell
	return "Emptied the Trash (" & itemCount & " items)."
end run
