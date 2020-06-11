local Discordia = require("discordia")
local Json = require("json")
local Io = require("io")
local Coro = require("coro-http")
local Client = Discordia.Client()
local Wait = require("./Libs/Code/Wait.lua")
local Shards = require("./Shards/Shards.lua")
local Commands = require("./Libs/Tables/Commands.lua")
local WebHooks = require("./Libs/Tables/WebHooks.lua")

local Token = "NjY1ODg2ODkyODAxMTMwNTE2.XmDO_A.KwrHtW9aatho7CIAgTSGfhgo1vo"
local Prefix = "!"

Client:on("ready", function()

	local Data = {}
	Data.Client = Client
	Data.Prefix = Prefix
	Data.Libs = {}
	Data.Libs.Code = {}
	Data.Libs.Code.Wait = Wait
	Data.Libs.Tables = {}
	Data.Libs.Tables.Commands = Commands
	Data.Libs.Tables.WebHooks = WebHooks
	

	for i, v in pairs(Shards) do
		v.Function(Data)
		print("Shard " .. v.Name .. " ready")
	end
end)


Client:run("Bot " .. Token)
Client:setGame({name = "this discord", type = 2})
