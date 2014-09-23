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

local function channel_exists(channel)
	for _,chan in ipairs(bot.chans) do
		if chan == channel then return true end
	end
	return false
end

local auth_queue = {}
local registered = {}

local hooks = {
	["OnChat"] = function(user, channel, message)
		bot:sendChat(bot.chans.global, "["..channel.."] "..user.nick..": "..message)
		
		if channel == bot.chans.announce then
			local key,action,param = message:match("^(%x+):(%u+)%s?%[?(.-)%]?$")
			if not key or not action then
				bot:sendChat(bot.chans.announce, user.nick..":SYNTAX ERROR")
				bot:debug("Syntax error on "..channel.." from "..user.nick)
				return
			end 
			bot:debug("["..channel.."] "..user.nick..": KEY="..key.." ACTION="..action)

			if action == "CONNECT" then
				auth_queue[user.nick] = key
				bot:sendChat(user.nick, key..":AUTHORIZATION REQUIRED")
			elseif action == "UPDATE" then
				local lat,lon = param:match("^(%d+%.%d+%u)(%d+%.%d+%u)$")
				if not lat or not lon then
					bot:sendChat(bot.chans.announce, user.nick..":SYNTAX ERROR")
					bot:debug("Syntax error on "..channel.." from "..user.nick)
					return
				end
				local data = registered[user.nick]
				if data then
					local loc = locator(lat,lon)
					if not loc then
						bot:sendChat(bot.chans.announce, user.nick..":INVALID LOCATION")
						bot:debug("Invalid location on "..channel.." from "..user.nick)
						return
					end
					loc = "#"..loc
					if data.channel then
						if data.channel == loc then
							bot:sendChat(bot.chans.announce, user.nick..":NO CHANGES")
							return
						end
					end
					if not channel_exists(loc) then
						bot:join(loc)
						table.insert(bot.chans, loc)
						-- set channel "invite only" and send invite
						bot:setMode({target=loc, add="i"})
					end
					bot:send("INVITE "..user.nick.." "..loc)
					registered[user.nick].channel = loc
				else
					bot:sendChat(bot.chans.announce, user.nick..":NOT REGISTERED")
					bot:debug("Not registered update from "..user.nick)
				end
			end
		end
		
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
			local ckey = auth_queue[user.nick]
			if ckey then
				local key,pass = message:match("^(%x+)%:(.+)$")
				if not key or not pass then
					bot:sendChat(user.nick, user.nick..":SYNTAX ERROR")
					bot:debug("Syntax error on /query from "..user.nick)
				elseif key ~= ckey then
					bot:sendChat(user.nick, key..":INVALID KEY")
					bot:debug("Invalid key ["..key.."] from "..user.nick.." (should be ["..ckey.."])")
				elseif auth(user.nick, key, pass) then
					bot:sendChat(user.nick, key..":AUTH OK")
					bot:debug("Authorized "..user.nick..", key "..key)
					registered[user.nick] = {key=key}
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