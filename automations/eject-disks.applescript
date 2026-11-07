-- @pls.description: Safely eject all external drives and disk images
-- @pls.example: eject all disks
-- @pls.example: eject my drives so I can unplug
-- @pls.example: unmount the external drive

on run argv
	-- Only disks under /Volumes: drives and disk images you mounted, not system ones like Xcode's simulator runtimes.
	tell application "Finder"
		set allNames to name of every disk whose ejectable is true
		set allURLs to URL of every disk whose ejectable is true
	end tell
	set diskNames to {}
	repeat with i from 1 to count of allNames
		if item i of allURLs starts with "file:///Volumes/" then set end of diskNames to item i of allNames
	end repeat
	if diskNames is {} then return "No disks to eject."
	set ejected to {}
	set busy to {}
	repeat with diskName in diskNames
		try
			tell application "Finder" to eject disk diskName
			set end of ejected to diskName as text
		on error
			set end of busy to diskName as text
		end try
	end repeat
	set AppleScript's text item delimiters to ", "
	set report to ""
	if ejected is not {} then set report to "Ejected " & (ejected as text) & "."
	if busy is not {} then set report to report & " Still in use, not ejected: " & (busy as text) & "."
	return report
end run
