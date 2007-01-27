tell application "iTunes"
	
	tell application "System Events"
		if not (exists process "iTunes") then
			return "{'position': '0', 'duration': '0', 'name': '(iTunes not running)', 'artist': '(iTunes not running)', 'album': '(iTunes not running)'}"
		end if
	end tell
	
	set pos to player position
	
	if kind of current track contains "stream" then
		set dur to 0
		set trackname to quoted form of (current stream title as text)
		set trackartist to quoted form of (name of current track as text)
		set trackalbum to "'Internet Radio'"
	else
		tell current track
			set dur to duration
			set trackname to quoted form of (name as text)
			set trackartist to quoted form of (artist as text)
			set trackalbum to quoted form of (album as text)
		end tell
	end if
	
	"{'position': '" & pos & "', 'duration': '" & dur & "', 'name': " & trackname & ", 'artist': " & trackartist & ", 'album': " & trackalbum & "}"
	
end tell