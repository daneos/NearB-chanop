-- app-chanop: irc chanop bot
-- Copyright (C) 2014 daneos.
-- Released under the MIT license. See LICENSE for details

require "irc.init" -- WTF??
local sleep = require "socket".sleep

local bot = {
	userinfo = {
		nick = "chanop",
		username = "chanop",
		realname = "Channel Operator",
	}, 
	server = "wiktor.ml",
	chans = {
		announce = "#announce",
		--global = "#global",
		debug = "#debug",
	},
	con = nil,
	ticks = 0,
	tickmax = 10000,
}

function bot:init()
-- start connection and initialize bot table
	self.con = irc.new(self.userinfo)
	self.con:connect(self.server)
	for _,chan in pairs(self.chans) do
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
	self:sendChat(self.chans.debug, message)
end

function bot:run()
-- bot main loop
	while true do
		self.con:think()
		sleep(0.01)
		self.ticks = self.ticks + 1

		if self.ticks > self.tickmax then
			self.ticks = 0
			for _,chan in ipairs(self.chans) do
				self:send("NAMES "..chan)
			end
		end
	end
end

function bot:reloadHooks(fn)
-- reload all hooks from a file
	local ok,hooks = xpcall(function() return loadfile(fn)() end, function(e) self:errorhandler(e) end)
	if ok then
		for h,func in pairs(hooks) do
			local ok,err = xpcall(function() self:unhook(h, h) end, function(e) self:errorhandler(e) end)
			self:hook(h, h, func)
			self:debug("Hook "..h.." reloaded successfully")
		end
	else
		self:debug("Hooks were not reloaded.")
	end
end

function bot:errorhandler(e)
	self:debug("PROTECTED ERROR: "..e)
end

return bot