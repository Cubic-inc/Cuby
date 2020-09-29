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

    {
        Name = "Status",
        Function  = require("./Status.lua")
    },

    {
        Name = "Channels",
        Function  = require("./Channels.lua")
    },


}

return Shards