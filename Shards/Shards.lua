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
        Name = "VoiceLogger",
        Function  = require("./VoiceLogger.lua")
    },

    {
        Name = "Pinger",
        Function  = require("./Pinger.lua")
    },


}

return Shards