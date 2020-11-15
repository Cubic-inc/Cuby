local Discordia = require("discordia")

local Clock = Discordia.Clock()
Clock:start()

local Client = Discordia.Client({cacheAllMembers = false})
local MusicClient = Discordia.Client()
local MilkClient = Discordia.Client()
local UtilsClient = Discordia.Client()
local ModClient = Discordia.Client()

_G.Client = Client
_G.MClient = MusicClient

local http = require("http")
local Json = require("json")
local Io = require("io")
local Coro = require("coro-http")
--local Spawn = require("coro-spawn")

local Wait = require("Code/Wait")
local TableToString = require("Code/TableToString")
local Shards = require("./Shards/Shards")
--local Commands = require("Tables/Commands")
local WebHooks = require("Tables/WebHooks")
local Status = require("Tables/Status")
local PostWebhook = require("Code/PostWebhook")
local CalcLevel = require("Code/CalcLevel")
local ReplaceString = require("Code/ReplaceString")
local Warn = require("Code/Warn")


local Token = require("./Tokens.lua").Client or os.getenv("TOKEN")
local MusicToken = require("./Tokens.lua").MusicClient or os.getenv("MUSICTOKEN")
local MilkToken = require("./Tokens.lua").MilkClient or os.getenv("MILKTOKEN")
local UtilsToken = require("./Tokens.lua").UtilsClient or os.getenv("UTILSTOKEN")
local ModToken = require("./Tokens.lua").ModClient or os.getenv("MODTOKEN")

local Prefix = "!"
local Guild = "657227821047087105"


local IsReady = false



Client:on("ready", function()

	

	if IsReady == true then return end
	IsReady = true

	local CommandHandler = require("Command"):Init(Client)

	
	local Data = {

		CommandHandler = CommandHandler,
		
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
				Save = require("Code/Save"),
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
		GlobalValues = {CurrentPinging = "658293584847699978", Channels = {}, Milk = true, HourWarnAmount = {}}
		
	
	}

	_G.Data = Data

	for i, v in pairs(Shards) do
			
		v.Function(Data)
		
		print("Runner " .. v.Name .. " ready!")
	end

	

	--local emoji = Client:getGuild("657227821047087105").emojis:find(function(e) return e.name == 'misfortune' end)
	--print(emoji.hash)

end)

Clock:on("hour", function()
	_G.Data.GlobalValues.HourWarnAmount = {}
end)

coroutine.wrap(function()

	local InfoBase = require("Code/Save"):GetDatabase("botinfo")
	local Status = InfoBase:GetAsync("Status")

	print("Starting CUBY API..")

	print("Starting MILKCLIENT")
	MilkClient:run("Bot " .. MilkToken)
	MilkClient:waitFor("ready")
	Wait(1000)
	
	print("Starting MUSICCLIENT")
	MusicClient:run("Bot " .. MusicToken)
	MusicClient:waitFor("ready")
	Wait(1000)
	
	print("Starting UTILSCLIENT")
	UtilsClient:run("Bot " .. UtilsToken)
	UtilsClient:waitFor("ready")
	Wait(1000)

	print("Starting MODCLIENT")
	ModClient:run("Bot " .. ModToken)
	ModClient:waitFor("ready")
	Wait(1000)

	print("Starting MAINCLIENT")
	Client:run("Bot " .. Token)
	Client:waitFor("ready")
	

	
	print("Setting games")
	MilkClient:setGame({name = "beerbot.ga", url = "https://www.youtube.com/watch?v=8gfLHpfjgDQ", type = 1})
	MusicClient:setGame({name = "Music", type = 2})
	Client:setGame({name = Status, type = 0})
end)()