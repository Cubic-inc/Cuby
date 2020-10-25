local Discordia = require("discordia")
local Client = Discordia.Client()
local MusicClient = Discordia.Client()
local MilkClient = Discordia.Client()

local http = require("http")
local Json = require("json")
local Io = require("io")
local Coro = require("coro-http")
--local Spawn = require("coro-spawn")

local Wait = require("./Libs/Code/Wait.lua")
local TableToString = require("./Libs/Code/TableToString.lua")
local Shards = require("./Shards/Shards.lua")
local Commands = require("./Libs/Tables/Commands.lua")
local WebHooks = require("./Libs/Tables/WebHooks.lua")
local Status = require("./Libs/Tables/Status.lua")
local PostWebhook = require("./Libs/Code/PostWebhook.lua")
local CalcLevel = require("./Libs/Code/CalcLevel.lua")
local ReplaceString = require("./Libs/Code/ReplaceString.lua")
local Warn = require("./Libs/Code/Warn.lua")


local Token = require("./Tokens.lua").Client
local MusicToken = require("./Tokens.lua").MusicClient
local MilkToken = require("./Tokens.lua").MilkClient
local Prefix = "!"
local Guild = "657227821047087105"

local IsReady = false



Client:on("ready", function()

	

	if IsReady == true then return end
	IsReady = true

	
	local Data = {
		
		Client = Client,
		MusicClient = MusicClient,
		MilkClient = MilkClient,
		Prefix = Prefix,
		Libs = {
			Code = {
				Wait = Wait,
				TableToString = TableToString,
				PostWebhook = PostWebhook,
				CalcLevel = CalcLevel,
				ReplaceString = ReplaceString,
				Save = require("./Libs/Code/Save.lua"),
				Warn = Warn
			},
			Tables = {
				Commands = Commands,
				WebHooks = WebHooks,
				Status = Status
			},
			Strings = {
				Roles = {
					Admin = "760223306417700875",
					Moderator = "760223388185788429",
				}
			}
		},
		GlobalValues = {CurrentPinging = nil, Channels = {}, Milk = true}
		
	
	}
	
	

	
		for i, v in pairs(Shards) do
			
			v.Function(Data)
			
			print("Runner " .. v.Name .. " ready!")
		end
    
end)

--[[
coroutine.wrap(function()
	local Data = {content = "test"}
	local res, body = Coro.request("POST", WebHooks.Logger, {{"Content-Type", "application/json"}}, Json.stringify(Data))

end)()
--]]

Client:run("Bot " .. Token)
Client:setGame({name = "deze discord", type = 2})

--MusicClient:run("Bot " .. MusicToken)
--MusicClient:setGame({name = "Muziek", type = 0})

MilkClient:run("Bot " .. MilkToken)
MilkClient:setGame({name = "!bier", type = 2})


local port = process.env["PORT"] or 3000
--print(port)

--[[
http.createServer(function(req, res)
	local body = ""
	res:setHeader("Content-Type", "text/html")
	res:setHeader("Content-Length", #body)
	res:finish(body)
end):listen(port)]]

--[[
coroutine.wrap(function()
local Save = require("./Libs/Code/Save.lua")
local DataBase = Save:GetDatabase("Levels")
print("line 114", DataBase:PostAsync("bonk", {}))
end)()]]

--print(require("./Libs/Code/Save").GetData("Levels", "test"))

--https://script.google.com/macros/s/AKfycbyxt-m0JKxrvY2dxm4LdTLK_5wvv_Xusdb9WQ0qRhZKU4Tk4kkA/exec

--[[
print(ReplaceString("Hallo {name} en welkom bij {comp}", {
	["name"] = "thimen",
	["comp"] = "cubic",
}))]]
--[[
local Count = 100
local Xp = 300

--[[
local LevelTable = {}

for i = 0, 10, 1 do
	LevelTable[i] = i * Count + ((i - 1) * Count)
	print("Level " .. i .. "\nXp " .. LevelTable[i])
end]]

--[[
Lvl = CalcLevel(Xp)
print(Lvl)]]

--print(os.getenv("TOKEN"))