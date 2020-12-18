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
        Name = "WebSite",
        Function  = require("./WebSite.lua")
    },

    {
        Name = "AutoMod",
        Function  = require("./AutoMod.lua")
    },

    {
        Name = "RoleManager",
        Function  = require("./RoleManager.lua")
    },
   
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