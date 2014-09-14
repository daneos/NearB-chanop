-- app-chanop: irc chanop bot
-- Copyright (C) 2014 daneos.
-- Released under the MIT license. See LICENSE for details

local bot = require "bot"

local function locator(lat,lon)
-- this is only dummy function
	return "JO72AX"
end

bot:init()

bot:hook("OnChat",
	function(user, channel, message)
		bot:sendNotice(bot.channels.global, "["..channel.."] "..user.nick..": "..message)
		
		if channel == bot.channels.announce then
			local key,lat1,lat2,ns,lon1,lon2,we,action = message:match("%[(%x+)%@(%d+)%.(%d+)(%u)(%d+)%.(%d+)(%u)%](%u+)")
			if not key or not lat1 or not lat2 or not ns or not lon1 or not lon2 or not we or not action then
				bot:sendChat(bot.channels.announce, user.nick..":SYNTAX ERROR")
				bot:debug("Syntax error on "..channel.." from "..user.nick)
				return
			end 
			bot:debug("["..channel.."] "..user.nick..": KEY="..key.." LAT="..lat1.."."..lat2..ns.." LON="..lon1.."."..lon2..we.." ACTION="..action)
			if action == "CONNECT" then
				lat = lat1.."."..lat2..ns
				lon = lon1.."."..lon2..we
				loc = "#"..locator(lat, lon)
				bot:join(loc)
				bot:sendChat(bot.channels.announce, user.nick..":JOIN "..loc)
			end		
		end
		
		if channel == bot.channels.debug and message == "quit" then
			bot:debug("Shutting down...")
			bot:disconnect("Shutting down...")
			os.exit()
		end
	end
)

bot:run()