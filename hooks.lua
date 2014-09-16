-- app-chanop: irc chanop bot
-- Copyright (C) 2014 daneos.
-- Released under the MIT license. See LICENSE for details

local bot = require "bot"

local function locator(lat,lon)

--
	local lengthofloc = 6
--

-- we add some degrees

	lon = lon + 180
	lat = lat + 90

-- to fix the coords

	local qth = {}

	qth[1] = string.char( string.byte("A") + math.floor(lon / 20) )
	qth[2] = string.char( string.byte("A") + math.floor(lat / 10) )

	qth[3] = string.char( string.byte("0") + math.floor((lon % 20)/2))
	qth[4] = string.char( string.byte("0") + math.floor((lat % 10)/1))

	qth[5] = string.char( string.byte("A") + math.floor( (lon - (math.floor(lon/2)*2)) / (5/60)))
	qth[6] = string.char( string.byte("A") + math.floor( (lat - (math.floor(lat/1)*1)) / (2.5/60)))


-- Above is some discrete shit (floor of floor or roof of longitude and latitude - but it's half past four when i write this code.
-- I'll figure what should it be later. Seriously ;) If you see that and it's not fixed, write me an issue
-- TODO: refactor countings, code another level of qth locator, smaller than 3rd one.

	local loc = qth[1]
	for i=2,lengthofloc do loc = (loc .. qth[i]) end

	return loc
end

local function auth(nick, key, pass)
-- this is only dummy function
	return true
end

local hooks = {
	["OnChat"] = function(user, channel, message)
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
		
		if channel == bot.chans.debug then
			if message == "quit" then
				bot:debug("Shutting down...")
				bot:disconnect("Shutting down...")
				os.exit()
			elseif message == "rehook" then
				bot:debug("Reloading hooks...")
				bot:reloadHooks("hooks.lua")
			end
		end
	end
}

return hooks