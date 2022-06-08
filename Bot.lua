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