Discordia = require("discordia")
Client = Discordia.Client()

local Announcer = "https://discordapp.com/api/webhooks/685522075103789073/TEIpxxeU-PmSbaso6v_-tPn2eSuMlQ2i23wExqIubm29hUxsL3gJOdBQQCQqMciRio95"

local Json = require("json")
local Token = "NjY1ODg2ODkyODAxMTMwNTE2.Xi2OBw.AgyyA9JZsjcx3B9pIjoagp7K1is"

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


Client:run('Bot NjY1ODg2ODkyODAxMTMwNTE2.Xi2OBw.AgyyA9JZsjcx3B9pIjoagp7K1is')



--for word in string.gmatch("Hello Lua user", "%a+") do print(word) end


--print(string.split())
