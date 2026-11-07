-- @pls.name: Apple Music now playing
-- @pls.description: Show what's playing in the Music app
-- @pls.example: what's playing?
-- @pls.example: what song is this?
-- @pls.example: who sings this

on run argv
	if not (application "Music" is running) then return "Music isn't open."
	tell application "Music"
		if player state is stopped then return "Nothing is playing."
		set t to current track
		set elapsed to my clock(player position)
		set total to my clock(duration of t)
		set stateNote to ""
		if player state is paused then set stateNote to " (paused)"
		return name of t & " — " & artist of t & " (" & album of t & "), " & elapsed & " of " & total & stateNote
	end tell
end run

on clock(seconds)
	set s to seconds as integer
	set secs to s mod 60
	set pad to ""
	if secs < 10 then set pad to "0"
	return ((s div 60) as text) & ":" & pad & secs
end clock
