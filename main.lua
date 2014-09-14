-- app-chanop: irc chanop bot
-- Copyright (C) 2014 daneos.
-- Released under the MIT license. See LICENSE for details

local bot = require "bot"

local function locator(lat,lon)
-- this is only dummy function
	return "JO72AX"
end

local function auth(nick, key, pass)
-- this is only dummy function
	return true
end

bot:init()

bot:hook("OnChat",
	function(user, channel, message)
		bot:sendChat(bot.chans.global, "["..channel.."] "..user.nick..": "..message)
		
		if channel == bot.chans.announce then
			local key,lat,lon,action,pass = message:match("%[(%x+)%@(%d+%.%d+%u)(%d+%.%d+%u)%](%u+) (.+)")
			if not key or not lat or not lon or not action or not pass then
				bot:sendChat(bot.chans.announce, user.nick..":SYNTAX ERROR")
				bot:debug("Syntax error on "..channel.." from "..user.nick)
				return
			end 
			bot:debug("["..channel.."] "..user.nick..": KEY="..key.." LAT="..lat.." LON="..lon.." ACTION="..action.." PASS="..pass)
			if action == "CONNECT" then
				if auth(user.nick, key, pass) then
					loc = "#"..locator(lat, lon)
					bot:join(loc)
					bot:sendChat(bot.chans.announce, user.nick..":JOIN "..loc)
					table.insert(bot.chans, loc)
				else
					bot:sendChat(bot.chans.announce, user.nick..":"..key.." UNAUTHORIZED")
					bot:debug("Authorization error for "..user.nick..", key "..key)
				end
			end		
		end
		
		if channel == bot.chans.debug and message == "quit" then
			bot:debug("Shutting down...")
			bot:disconnect("Shutting down...")
			os.exit()
		end
	end
)

bot:hook("OnNotice",
	function(user,channel, message)
		bot:debug("["..channel.."] "..user.nick..": "..message)
	end
)

bot:run()