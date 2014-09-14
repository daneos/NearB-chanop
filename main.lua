-- app-chanop: irc chanop bot
-- Copyright (C) 2014 daneos.
-- Released under the MIT license. See LICENSE for details

local bot = require "bot"

bot:init()
bot:reloadHooks("hooks.lua")
bot:run()