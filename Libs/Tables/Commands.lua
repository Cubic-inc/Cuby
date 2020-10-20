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
            Data.PreMSG:setContent(":boom: **poof** '⠀'")
        end
    },

    {
        Name = "bier",
        Desc = "?",
        Client = 3,
        Perms = {Owner = true, Admin = true, Moderator = true, User = true},
        Aliases = {"404"},
        Function = require("./Commands/Bier.lua")
    },

    {
        Name = "mute",
        Desc = "?",
        Client = 1,
        Perms = {Owner = true, Admin = true, Moderator = true, User = false},
        Aliases = {},
        Function = require("./Commands/Mute.lua")
    },

    {
        Name = "p",
        Desc = "?",
        Client = 1,
        Perms = {Owner = true, Admin = true, Moderator = true, User = false},
        Aliases = {"play", "pn"},
        Function = function(Data)
            Data.OrgMSG:hideEmbeds()
            Data.PreMSG:delete()
        end
    },

    {
        Name = "info",
        Desc = "gets the info of the bot",
        Client = 1,
        Perms = {Owner = true, Admin = true, Moderator = true, User = true},
        Aliases = {"data", "uptime", "time"},
        Function = require("./Commands/Info.lua")
    },

    {
        Name = "level",
        Desc = "verkijg je level",
        Client = 1,
        Perms = {Owner = true, Admin = true, Moderator = true, User = true},
        Aliases = {"rank", "lvl"},
        Function = require("./Commands/Level.lua")
    },



}