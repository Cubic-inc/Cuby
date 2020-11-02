local Discordia = require("discordia")

local Clock = Discordia.Clock()
Clock:start()

local Client = Discordia.Client({cacheAllMembers = true})
local MusicClient = Discordia.Client()
local MilkClient = Discordia.Client()

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
local MusicToken = require("./Tokens.lua").MusicClient
local MilkToken = require("./Tokens.lua").MilkClient or os.getenv("MILKTOKEN")
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

	local PingCommand = CommandHandler.New()

	PingCommand:SetName("ping")
	
	PingCommand:SetFunction(function(MSG) MSG:reply("Pong! <:hotcomputer:685867382073196712>") end)

	local InfoCommand = CommandHandler.New()
	InfoCommand:SetName("info")
	
	InfoCommand:SetFunction(function(MSG)
		MSG:reply({content = "⠀", embed = {
			title = "Bot info",
			author = {name = "Cuby", icon_url = Client.user.avatarURL},
			fields = {
				{name = "Version", value = "Unknown!", inline = true},
				{name = "Uptime", value = "N/A", inline = true},
				{name = "Creator", value = "<@533536581055938580>", inline = true},
	
			}
		}})
	end)

	local CoolCommand = CommandHandler.New()
	CoolCommand:SetName("cool")
	
	CoolCommand:SetFunction(function(MSG)
		MSG:reply("Jij bent " .. math.random(0, 100) .. "% Cool :ice_cube: " .. Data.Author.mentionString)
	end)

end)

Clock:on("hour", function()
	_G.Data.GlobalValues.HourWarnAmount = {}
end)



Client:run("Bot " .. Token)
Client:setGame({name = "deze discord", type = 2})

MilkClient:run("Bot " .. MilkToken)
MilkClient:setGame({name = "!bier", type = 2})



