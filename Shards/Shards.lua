local Shards = {

    {
        Name = "CommandHandler",
        Function  = require("./CommandHandler.lua")
    },

    {
        Name = "ErrorCatch",
        Function = require("./ErrorCatch.lua")
    },

    {
        Name = "Logger",
        Function  = require("./VoiceLogger.lua")
    },

    {
        Name = "Pinger",
        Function  = require("./Pinger.lua")
    },

    {
        Name = "Status",
        Function  = require("./Status.lua")
    },

    {
        Name = "Channels",
        Function  = require("./Channels.lua")
    },

    {
        Name = "WebSite",
        Function  = require("./WebSite.lua")
    },

    {
        Name = "AutoMod",
        Function  = require("./Levels.lua")
    },

    {
        Name = "ConsoleCommands",
        Function  = require("./ConsoleCommands.lua")
    },

    {
        Name = "MiniGames",
        Function  = require("./MiniGames.lua")
    },


}

return Shards