-- @pls.description: Add a reminder to the Reminders app, optionally due in a number of minutes
-- @pls.param text: string -- What to be reminded of
-- @pls.param in_minutes: int(0...10080) = 0 -- Minutes from now until it's due, when the request says when; 0 means no due time
-- @pls.example: remind me to call mom
-- @pls.example: remind me in 20 minutes to check the oven
-- @pls.example: set a reminder to take out the bins in 2 hours

on run argv
	set reminderText to item 1 of argv
	set minutes to (item 2 of argv) as integer
	tell application "Reminders"
		if minutes = 0 then
			make new reminder with properties {name:reminderText}
			return "Reminder added: " & reminderText
		end if
		make new reminder with properties {name:reminderText, due date:(current date) + minutes * 60}
	end tell
	return "Reminder set for " & (do shell script "date -v+" & minutes & "M '+%a %H:%M'") & ": " & reminderText
end run
