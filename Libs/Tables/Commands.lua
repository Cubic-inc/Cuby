return {

    {
        Name = "ping",
        Desc = "Pong",
        Aliases = {"test"},
        Function = function(Data)
            Data.PreMSG:setContent("Pong")
        end

    },

    {
        Name = "setcurrentping",
        Desc = "Set the ping",
        Aliases = {"setping"},
        Function = function(Data)
            --print(Data.ShardData.Libs.Code.TableToString(Data.OrgMSG.mentionedUsers.first.username))

            local Mentioned = Data.Mentioned
            print(#Mentioned)
            print(Data.cleanContent)
            --print(Data.ShardData.Libs.Code.TableToString(Data.Mentioned))
            if Mentioned[1] then
                Data.PreMSG:setContent("Set ping to user: " .. tostring(Mentioned[1].name))
                
                Data.ShardData.CurrentPinging = Mentioned[1].id
            else
                Data.PreMSG:setContent("Set ping to: nil")
            end
            
            --Data.ShardData.CurrentPinging = 533536581055938580
	   
        end

    },

    {
        Name = "lockchannel",
        Desc = "lock your channel",
        Enabled = true,
        Aliases = {},
        Function = require("./Commands/ChannelCommands.lua").Lock
    
    },

    {
        Name = "unlockchannel",
        Desc = "unlock your channel",
        Enabled = true,
        Aliases = {},
        Function = require("./Commands/ChannelCommands.lua").Unlock
    
    },

    {
        Name = "crab",
        Desc = "?",
        Enabled = true,
        Aliases = {},
        Function = require("./Commands/Crab.lua")
    
    },

    {
        Name = "cool",
        Desc = "?",
        Enabled = true,
        Aliases = {"koel", "koud", "warm"},
        Function = require("./Commands/Cool.lua")
    
    },



}