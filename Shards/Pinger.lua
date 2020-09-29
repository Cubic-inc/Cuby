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

	local Amount = 1

    coroutine.wrap(function()
		while true do Wait(2000)
			--print(Amount)
			
			if Data.CurrentPinging then
				coroutine.wrap(function()
					
					
					
					for i, v in pairs(WebHooks.Pingers) do
						local Data = {content = Client:getUser(Data.CurrentPinging).mentionString .. " " .. Amount}
						local Encoded = Json.stringify(Data)
						local res, body = Coro.request("POST", v, {{"Content-Type", "application/json"}}, Encoded)
						Amount = Amount + 1
					end
				end)()
			else 
				--print(Data.CurrentPinging)
			end
			
		end
    end)()


end