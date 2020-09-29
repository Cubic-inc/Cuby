return function(Data)

    local Client = Data.Client
    local Prefix = Data.Prefix
    local Wait = Data.Libs.Code.Wait
    local TableToString = Data.Libs.Code.TableToString
    local Commands = Data.Libs.Tables.Commands
    local WebHooks = Data.Libs.Tables.WebHooks
	
    local Coro = require("coro-http")
    local Json = require("json")
    local LoggerLink = WebHooks.Logger

    coroutine.wrap(function()
	while true do Wait(2000)
	   --print(true)
	   if Data.CurrentPinging then
	   	coroutine.wrap(function()
           	local Data = {content = Client:getUser(Data.CurrentPinging). mentionString}
			local Encoded = Json.stringify(Data)
           	
			for i, v in pairs(WebHooks.Pingers) do
            		
            	local res, body = Coro.request("POST", v, {{"Content-Type", "application/json"}}, Encoded)
		
			end
	  	end)()
	   end
	end
    end)()


end