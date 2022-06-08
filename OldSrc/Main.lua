local Discordia = require("discordia")
local SlashClient = require("discordia-slash")
local Logger = require("Libs/Logger")
local Sql = require("sqlite3")

Database = Sql.open("./Database/Cuby.db")

--[[
local t = Database:exec("SELECT Experience FROM Levels WHERE UserId == 1")

p(t)
p(t.Experience)
print(t.Experience[1])
print(type(t.Experience[1]))

local f = Database:exec("UPDATE Levels SET Experience = 234234 WHERE UserId == 56;")
]]


local Client = Discordia.Client()
Client:useSlashCommands()

local ModuleList = require("./Modules/List.lua")

Client:on("slashCommandsReady", function()
    p()
    Logger.Info("Client Ready!")

    if require("./Config/Config.lua").DevMode then
        for Index, Command in pairs(Client:getGuild(require("./Config/Config.lua").TestingServerId):getSlashCommands()) do
            Command:delete()
        end
    end

    local Params = {
        Client = Client,
        SlashClient = SlashClient,
        Logger = Logger,
        ModuleList = ModuleList,
        PublishCommand = require("PublishCommand"),
        DataBaseConnection = require("sqlite3").open("./DataBase/Cuby.db")
    }

    Logger.Info("Starting Modules...")
    p()

    for Index, Module in pairs(ModuleList) do
        Logger.Info("Starting Main Module from " .. Module.Name)
        coroutine.wrap(Module.Main)(Params)
        Logger.Info("Main module started!")
        Logger.Info("Starting commands")

        for CommandIndex, Command in pairs(Module.Commands) do
            coroutine.wrap(Command)(Params)
            Logger.Info(CommandIndex .. " Started")
        end

        Logger.Info("Module fully started!")
        p()
    end

    Logger.Info("Fully started bot!")
end)

Client:run("Bot " .. require("Config/Tokens").Main)