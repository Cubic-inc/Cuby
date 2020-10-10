return {

    {
        Name = "ping",
        Desc = "Pong",
        Perms = {Owner = true, Admin = true, Moderator = true, User = true},
        Aliases = {"test"},
        Function = function(Data)
            Data.PreMSG:setContent("Pong")
        end
    },

    {
        Name = "lockchannel",
        Desc = "lock your channel",
        Perms = {Owner = true, Admin = true, Moderator = true, User = true},
        Aliases = {},
        Function = require("./Commands/ChannelCommands.lua").Lock
    },

    {
        Name = "unlockchannel",
        Desc = "unlock your channel",
        Perms = {Owner = true, Admin = true, Moderator = true, User = true},
        Aliases = {},
        Function = require("./Commands/ChannelCommands.lua").Unlock
    },

    {
        Name = "crab",
        Desc = "?",
        Perms = {Owner = true, Admin = true, Moderator = true, User = true},
        Aliases = {},
        Function = require("./Commands/Crab.lua")
    },

    {
        Name = "cool",
        Desc = "?",
        Perms = {Owner = true, Admin = true, Moderator = true, User = true},
        Aliases = {"koel", "koud", "warm"},
        Function = require("./Commands/Cool.lua")
    },
	
	{
        Name = "warn",
        Desc = "?",
        Perms = {Owner = true, Admin = true, Moderator = true, User = false},
        Aliases = {},
        Function = require("./Commands/Warn.lua")
    },

    {
        Name = "blank",
        Desc = "?",
        Perms = {Owner = true, Admin = true, Moderator = true, User = false},
        Aliases = {},
        Function = function(Data)
            Data.PreMSG:setContent("*poof * '⠀'")
        end
    },



}