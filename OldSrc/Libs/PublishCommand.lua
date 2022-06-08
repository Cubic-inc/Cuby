return function(Client, Command)
    local Config = require("../Config/Config.lua")

    if Config.DevMode then
        Client:getGuild(Config.TestingServerId):slashCommand(Command)
    else
        Client:slashCommand(Command)
    end

end