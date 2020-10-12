return {

    {
        Name = "ping",
        Desc = "Pong",
        Client = 1,
        Perms = {Owner = true, Admin = true, Moderator = true, User = true},
        Aliases = {"test"},
        Function = function(Data)
            Data.PreMSG:setContent("Pong")
        end
    },

    {
        Name = "lockchannel",
        Desc = "lock your channel",
        Client = 1,
        Perms = {Owner = true, Admin = true, Moderator = true, User = true},
        Aliases = {},
        Function = require("./Commands/ChannelCommands.lua").Lock
    },

    {
        Name = "unlockchannel",
        Desc = "unlock your channel",
        Client = 1,
        Perms = {Owner = true, Admin = true, Moderator = true, User = true},
        Aliases = {},
        Function = require("./Commands/ChannelCommands.lua").Unlock
    },

    {
        Name = "crab",
        Desc = "?",
        Client = 1,
        Perms = {Owner = true, Admin = true, Moderator = true, User = true},
        Aliases = {},
        Function = require("./Commands/Crab.lua")
    },

    {
        Name = "cool",
        Desc = "?",
        Client = 1,
        Perms = {Owner = true, Admin = true, Moderator = true, User = true},
        Aliases = {"koel", "koud", "warm"},
        Function = require("./Commands/Cool.lua")
    },
	
	{
        Name = "warn",
        Desc = "?",
        Client = 1,
        Perms = {Owner = true, Admin = true, Moderator = true, User = false},
        Aliases = {},
        Function = require("./Commands/Warn.lua")
    },

    {
        Name = "blank",
        Desc = "?",
        Client = 1,
        Perms = {Owner = true, Admin = true, Moderator = true, User = true},
        Aliases = {},
        Function = function(Data)
            Data.PreMSG:setContent("**poof** '⠀'")
        end
    },

    {
        Name = "milk",
        Desc = "?",
        Client = 3,
        Perms = {Owner = true, Admin = true, Moderator = true, User = true},
        Aliases = {},
        Function = function(Data)
            local GlobalData = Data.ShardData.GlobalValues

            if not Data.Args[1] then
                Data.PreMSG:setContent("Geen sub commando gegeven")
            elseif string.lower(Data.Args[1]) == "drink" and GlobalData.Milk == true then
                Data.PreMSG:setContent("Slurp Slurp")
                GlobalData.Milk = false
            elseif string.lower(Data.Args[1]) == "drink" and GlobalData.Milk == false then
                Data.PreMSG:setContent("Het Glas is leeg")
            elseif string.lower(Data.Args[1]) == "fill" and GlobalData.Milk == false then
                Data.PreMSG:setContent("Klok Klok")
                GlobalData.Milk = true
            elseif string.lower(Data.Args[1]) == "fill" and GlobalData.Milk == true then
                Data.PreMSG:setContent("Het glas is al vol")
            end

        end
    },

    {
        Name = "mute",
        Desc = "?",
        Client = 1,
        Perms = {Owner = true, Admin = true, Moderator = true, User = false},
        Aliases = {},
        Function = function(Data)

            local MentionedArray = Data.OrgMSG.mentionedUsers:toArray()
            if MentionedArray[1] then
                local Member = Data.Guild:getMember(MentionedArray[1].id)
                if Member then
                    
                    Data.PreMSG:setContent("")

                    local Rede = Data.Args[1] or "Geen Rede Gegeven"

                    if Member:hasRole("765149108985266217") then
                        Member:removeRole("765149108985266217")
                        Data.PreMSG:update({content = nil, embed = {description = ":white_check_mark: **" .. Member.tag .. "** Is Geunmute"}})
                    else
                        Member:addRole("765149108985266217")
                        Data.PreMSG:update({content = nil, embed = {description = ":white_check_mark: **" .. Member.tag .. "** Is Gemute | " .. Rede}})
                    end
                end
            else
                Data.PreMSG:setContent("Je moet iemand pingen!")
            end
        end
    },



}