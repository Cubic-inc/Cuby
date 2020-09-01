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

}

return Shards