#!/bin/zsh
# @pls.description: Quit all open apps except the ones the request names
# @pls.param keep: string? -- App names to leave open, only those the request names
# @pls.confirm: true
# @pls.preview: true
# @pls.example: quit everything
# @pls.example: close all apps except Safari and Mail
# @pls.example: clean slate, quit all my apps

# "Safari and Mail" or "Safari, Mail" → one name per argument.
setopt extended_glob
keep=(${(s:,:)${PLS_KEEP// and /,}})
keep=(${keep## ##})
keep=(${keep%% ##})

# Finder and the app pls runs in (the frontmost one) always stay. Apps quit normally, so unsaved work still asks.
# The first argument says whether to quit or only say what would quit (a preview).
osascript - "${PLS_PREVIEW:+preview}" "${keep[@]}" <<'APPLESCRIPT'
on run argv
	set previewing to (item 1 of argv) is "preview"
	set argv to rest of argv
	tell application "System Events"
		set frontName to name of first application process whose frontmost is true
		set appNames to name of every application process whose background only is false
		set appIDs to bundle identifier of every application process whose background only is false
	end tell
	set quitNames to {}
	set keptNames to {}
	repeat with i from 1 to count of appNames
		set appName to item i of appNames
		set kept to (appName is "Finder") or (appName is frontName)
		repeat with wanted in argv
			ignoring case
				if appName is (wanted as text) then set kept to true
			end ignoring
		end repeat
		if kept then
			set end of keptNames to appName
		else
			if not previewing then
				ignoring application responses
					tell application id (item i of appIDs) to quit
				end ignoring
			end if
			set end of quitNames to appName
		end if
	end repeat
	set AppleScript's text item delimiters to ", "
	if quitNames is {} then return "Nothing to quit; open: " & (keptNames as text) & "."
	if previewing then return "Would quit " & (quitNames as text) & ". Keeps " & (keptNames as text) & "."
	return "Quit " & (quitNames as text) & ". Still open: " & (keptNames as text) & "."
end run
APPLESCRIPT
