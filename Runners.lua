local Table = table 
local String = string
local Json = require("json")
local TableToString = require("./Libs/TableToString.lua")

--local Wait = require("./Libs/Wait.lua")
local Wait = require("timer").sleep

return {

    {

        Name = "Verify",

        Function = function(RunnerData)
            
        end

    },

    {

        Name = "Command-handler",

        Function = require("./Data/Runners/CommandHandler.lua")

    },

}