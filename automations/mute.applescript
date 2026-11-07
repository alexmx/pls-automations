-- @pls.description: Mute or unmute the sound, keeping the volume level
-- @pls.param mode: enum(mute|unmute|toggle) = mute -- Whether the sound should be muted
-- @pls.example: mute
-- @pls.example: unmute the sound
-- @pls.example: I'm on a call, silence the mac

on run argv
	set mode to item 1 of argv
	if mode is "toggle" then
		set muted to not (output muted of (get volume settings))
	else
		set muted to (mode is "mute")
	end if
	set volume output muted muted
	if muted then return "Sound is muted."
	return "Sound is on."
end run
