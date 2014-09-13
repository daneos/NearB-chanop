-- app-chanop: irc chanop bot
-- Copyright (C) 2014 daneos.
-- Released under the MIT license. See LICENSE for details

require "irc.init" -- WTF??
local sleep = require "socket".sleep

s = irc.new{nick = "chanop"}

s:hook("OnChat",
	function(user, channel, message)
		print(".")
		s:sendNotice("#global", "["..channel.."] "..user.nick..": "..message)
		if channel == "#announce" then
				local key,lat1,lat2,ns,lon1,lon2,we,action = message:match("%[(%x+)%@(%d+)%.(%d+)(%u)(%d+)%.(%d+)(%u)%](%u+)")
				s:sendNotice("#debug", "["..channel.."] "..user.nick..": KEY="..key.." LAT="..lat1.."."..lat2..ns.." LON="..lon1.."."..lon2..we.." ACTION="..action)
			end
		end
		if channel == "#debug" and message == "QUIT" then
			debug("Shutting down...")
			exit(0)
		end
	end
)

s:connect("wiktor.ml")
s:join("#test")
s:join("#global")
s:join("#announce")
s:join("#debug")
while true do
	s:think()
	sleep(0.5)
end