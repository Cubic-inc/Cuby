<<<<<<< HEAD
Discordia = require("discordia")
Client = Discordia.Client()

local Announcer = ""

local Json = require("json")
local Token = ""

local String = string
local Table = table

local Prefix = "!"





Client:on("ready", function()

    print("")
    print("Setting Status...")
    print("")
    Client:setGame("Coded in [LUA]")

    --Creating runner data
    local Data = {}

    Data.Discordia = Discordia
    Data.Client = Client
    Data.Prefix = Prefix
    Data.AnnouncerLink = Announcer

    print("Starting runners...")
    --Starting runners
    for i, v in pairs(require("./Runners.lua")) do

        v.Function(Data)


        print("Started runner " .. v.Name)
    end

    print("")
    print("The bot is now online on " .. #Client.guilds .. " Servers!")
    print("")
end)


Client:run('Bot ')



--for word in string.gmatch("Hello Lua user", "%a+") do print(word) end


--print(string.split())
=======
coroutine.wrap(function()

print("STARTING...")


local Start = require("StartUp")()

local Client = _G.Client
local Format = _G.Format





Client:on("allReady", function()

    local Modules = {

        Moderation = {
            Main = require("./Modules/Moderation.lua"),
            Commands = {
                require("./Commands/Moderation.lua")
            }
        },

        OwnerHandler = {
            Main = require("./Modules/Owner.lua"),
            Commands = {
                require("./Commands/Owner.lua")
            }
        },

        Commands = {
            Main = require("./Modules/Commands.lua"),
            Commands = {
                require("./Commands/Commands.lua")
            }
        },

        Logger = {
            Main = require("./Modules/Logger.lua"),
            Commands = {

            }
        },

        BumpBonker = {
            Main = require("./Modules/BumpBonker.lua"),
            Commands = {

            }
        },

        Leveling = {
            Main = require("./Modules/Leveling.lua"),
            Commands = {
                require("./Commands/Leveling.lua")
            }
        },

        Stickies = {
            Main = require("./Modules/Stickies.lua"),
            Commands = {
                require("./Commands/Stickies.lua")
            }
        }

    }

    print()

    for i, v in pairs(Modules) do
        Client:info(Format("Trying to start Module: '%s'", tostring(i)))
        v.Main()
        Client:info(Format("Started Main: '%s' Function: '%s'", tostring(i), tostring(v.Main)))

        Client:info("Checking command modules...")

        for b, n in pairs(v.Commands) do
            Client:info("Starting: " .. b)
            n()
            Client:info("Done")
        end

        Client:info(Format("Started Module: '%s'", tostring(i)))
        print()

    end

    print()
    Client:info("Fully started!")
    print()

    Client:info("Starting website....")
    print()

    require("./WebsiteData/Website")()



end)

end)()
>>>>>>> Cuby-v5
