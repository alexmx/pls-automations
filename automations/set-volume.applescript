-- @pls.description: Set the sound output volume to a level from 0 to 100
-- @pls.param level: int(0...100) -- Volume in percent
-- @pls.example: set the volume to 30
-- @pls.example: volume 70
-- @pls.example: make it quieter, like 20%

on run argv
	set level to (item 1 of argv) as integer
	set volume output volume level
	return "Volume is " & level & "%."
end run
