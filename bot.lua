-- app-chanop: irc chanop bot
-- Copyright (C) 2014 daneos.
-- Released under the MIT license. See LICENSE for details

require "irc.init" -- WTF??
local sleep = require "socket".sleep

local bot = {
	userinfo = {
		nick = "chanop",
	}, 
	server = "wiktor.ml",
	channels = {
		announce = "#announce",
		global = "#global",
		debug = "#debug",
	},
	con		= nil,
}

function bot:init()
-- start connection and initialize bot table
	self.con = irc.new(self.userinfo)
	self.con:connect(self.server)
	for _,chan in pairs(self.channels) do
		self.con:join(chan)
	end

	local mt = {
		__index = self.con
	}
	setmetatable(self, mt)
end

function bot:debug(message)
-- print debug message
	print(message)
	self.con:sendNotice(self.channels.debug, message)
end

function bot:run()
-- bot main loop
	while true do
		self.con:think()
		sleep(0.5)
	end
end

return bot