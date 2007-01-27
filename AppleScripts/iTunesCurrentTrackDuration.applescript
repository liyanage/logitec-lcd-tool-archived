tell application "System Events" to set iTunesRunning to exists process "iTunes"
if (not iTunesRunning) then return "(iTunes not running)"
tell application "iTunes" to duration of current track