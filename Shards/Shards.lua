local Shards = {

    {
        Name = "Logger",
        Function  = require("./VoiceLogger.lua")
    },

    {
        Name = "MusicHost",
        Function  = require("./Music.lua")
    },

    {
        Name = "Commands",
        Function  = require("./Commands.lua")
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
        Function  = require("./AutoMod.lua")
    },

    --[[{
        Name = "MiniGames",
        Function  = require("./MiniGames.lua")
    },]]
   
    {
        Name = "ModMail",
        Function  = require("./ModMail.lua")
    },

		{
        Name = "Pinger",
        Function  = require("./Pinger.lua")
    },


}

return Shards