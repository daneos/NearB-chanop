-- app-chanop: irc chanop bot
-- Copyright (C) 2014 daneos.
-- Released under the MIT license. See LICENSE for details

local bot = require "bot"
local locator = require "locator"

local function auth(nick, key, pass)
-- this is only dummy function
	return true
end

local auth_queue = {}

local hooks = {
	["OnChat"] = function(user, channel, message)
		bot:sendChat(bot.chans.global, "["..channel.."] "..user.nick..": "..message)

		-- announce	channel
		if channel == bot.chans.announce then
			local key,lat,lon,action = message:match("^%[(%x+)%@(%d+%.%d+%u)(%d+%.%d+%u)%](%u+)$")
			if not key or not lat or not lon or not action then
				bot:sendChat(bot.chans.announce, user.nick..":SYNTAX ERROR")
				bot:debug("Syntax error on "..channel.." from "..user.nick)
				return
			end 
			bot:debug("["..channel.."] "..user.nick..": KEY="..key.." LAT="..lat.." LON="..lon.." ACTION="..action)
			if action == "CONNECT" then
				auth_queue[user.nick] = {key=key,lat=lat,lon=lon}
				bot:sendChat(user.nick, key..":AUTHORIZATION REQUIRED")
			end		
		end
		
		-- debug channel
		if channel == bot.chans.debug then
			local cmd,param = message:match("^(%w+)%s?(.*)$")
			if cmd == "quit" then
				bot:debug("Shutting down...")
				bot:disconnect("Shutting down...")
				os.exit()
			elseif cmd == "rehook" then
				if param == "" then
					bot:debug("Reloading hooks from default...")
					bot:reloadHooks("hooks.lua")
				else
					bot:debug("Reloading hooks from ["..param.."]...")
					bot:reloadHooks(param)
				end
			elseif cmd == "irc" then
				if not param then return end
				bot:send(param)
			end
		end

		-- messages on /query
		if channel == bot.userinfo.nick then
			local data = auth_queue[user.nick]
			if data then
				local key,pass = message:match("^(%x+)%:(.+)$")
				if not key or not pass then
					bot:sendChat(user.nick, user.nick..":SYNTAX ERROR")
					bot:debug("Syntax error on /query from "..user.nick)
				elseif key ~= data.key then
					bot:sendChat(user.nick, key..":INVALID KEY")
					bot:debug("Invalid key ["..key.."] from "..user.nick.." (should be ["..data.key.."])")
				elseif auth(user.nick, key, pass) then
					loc = "#"..locator(data.lat, data.lon)
					bot:join(loc)
					table.insert(bot.chans, loc)
					-- set channel "invite only" and send invite
					bot:setMode({target=loc, add="i"})
					bot:send("INVITE "..user.nick.." "..loc)
				else
					bot:sendChat(user.nick, user.nick..":"..key.." UNAUTHORIZED")
					bot:debug("Authorization error for "..user.nick..", key "..key)
				end
				auth_queue[user.nick] = nil
			else
				bot:sendChat(user.nick, user.nick..":NOT ALLOWED")
				bot:debug("Illegal /query from "..user.nick)
			end
		end
	end,

	["OnNotice"] = function(user, channel, message)
		bot:debug("NOTICE: ["..channel.."]: "..message)
	end,

	["OnRaw"] = function(message)
		print("RAW: "..message)
		return nil
	end,
}

return hooks