local Discordia = require("discordia")
local Client = Discordia.Client()
local MusicClient = Discordia.Client()


local Json = require("json")
local Io = require("io")
local Coro = require("coro-http")
local Spawn = require("coro-spawn")

local Wait = require("./Libs/Code/Wait.lua")
local TableToString = require("./Libs/Code/TableToString.lua")
local Shards = require("./Shards/Shards.lua")
local Commands = require("./Libs/Tables/Commands.lua")
local WebHooks = require("./Libs/Tables/WebHooks.lua")



local Token = "NjY1ODg2ODkyODAxMTMwNTE2.XmDO_A.KwrHtW9aatho7CIAgTSGfhgo1vo"
local MusicToken = "NzUwMjQzMTgwNTE5MjI3NDQy.X03saQ.mtnicAE-55JkjlycBXcJh0YG4IY"
local Prefix = "!"

Client:on("ready", function()

	local Data = {
		
		Client = Client,
		Prefix = Prefix,
		Libs = {
			Code = {
				Wait = Wait,
				TableToString = TableToString
			},
			Tables = {
				Commands = Commands,
				WebHooks = WebHooks
			}
		}
	
	}
	
	

	
		for i, v in pairs(Shards) do
			
			v.Function(Data)
			
			print("Shard " .. v.Name .. " ready")
		end
    
end)

--[[
coroutine.wrap(function()
	local Data = {content = "test"}
	local res, body = Coro.request("POST", WebHooks.Logger, {{"Content-Type", "application/json"}}, Json.stringify(Data))

end)()
--]]

Client:run("Bot " .. Token)
MusicClient:run("Bot " .. MusicToken)
Client:setGame({name = "deze discord", type = 2})
MusicClient:setGame({name = "Muziek", type = 1})





MusicClient:on("ready", function()
	--MusicClient.voice:loadOpus('libopus-x86')
	--MusicClient.voice:loadSodium('libsodium-x86')
	print(MusicClient.voice)

	local MusicConnection = MusicClient:getChannel("658677095534428166"):join()
end)


local http = require("http")

-- "A web dyno must bind to its assigned $PORT within 60 seconds of startup."
-- see https://devcenter.heroku.com/articles/dynos#web-dynos
local port = process.env["PORT"]

http.createServer(function(req, res)
	local body = "Hello world\n"
	res:setHeader("Content-Type", "text/plain")
	res:setHeader("Content-Length", #body)
	res:finish(body)
end):listen(port)

print("Server listening on port "..port)
