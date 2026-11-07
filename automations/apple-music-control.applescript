-- @pls.name: Apple Music control
-- @pls.description: Play, pause, skip or go back a track in the Music app
-- @pls.param action: enum(play|pause|next|previous) = play -- What to do
-- @pls.example: pause the music
-- @pls.example: next song
-- @pls.example: go back to the last track
-- @pls.example: play some music

on run argv
	set action to item 1 of argv
	if action is not "play" and not (application "Music" is running) then return "Music isn't open."
	tell application "Music"
		if action is "play" then
			play
		else if action is "pause" then
			pause
			return "Paused."
		else if action is "next" then
			next track
		else
			back track
		end if
		try
			return "Playing: " & name of current track & " — " & artist of current track
		on error
			return "Nothing is playing."
		end try
	end tell
end run
