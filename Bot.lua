local Discordia = require("discordia")
local Client = Discordia.Client()

local Token = "NjY1ODg2ODkyODAxMTMwNTE2.XmDO_A.KwrHtW9aatho7CIAgTSGfhgo1vo"
local Prefix = "!"

Client:on('messageCreate', function(Message)
	local Data = {}
	
	if string.sub(Message.content, 1, 1) == Prefix then

		local Args = {}

		

	end
end)


Client:run("Bot " .. Token)
print("bot is good to go!")