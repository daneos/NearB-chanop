-- app-chanop: irc chanop bot
-- Copyright (C) 2014 daneos.
-- Released under the MIT license. See LICENSE for details

require "irc.init" --WTF??
local sleep = require "socket".sleep

local s = irc.new{nick = "chanop"}

s:hook("OnChat",
	function(user, channel, message)
		print(("[%s] %s: %s"):format(channel, user.nick, message))
	end
)

s:connect("wiktor.ml")
s:join("#test")

while true do
	s:think()
	sleep(0.5)
end