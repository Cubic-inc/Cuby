return function(Data)

    local Client = Data.Client
    local Prefix = Data.Prefix
    local Wait = Data.Libs.Code.Wait
    local TableToString = Data.Libs.Code.TableToString
    local Commands = Data.Libs.Tables.Commands
    local WebHooks = Data.Libs.Tables.WebHooks
    local PostWebhook = Data.Libs.Code.PostWebhook
	
    local Coro = require("coro-http")
    local Json = require("json")
    local LoggerLink = WebHooks.Logger

	local Amount = 1

    coroutine.wrap(function()
	    while true do Wait(2000)
	   --print(true)
	        if Data.CurrentPinging then
	   	        coroutine.wrap(function()
           	        local Data = {content = Client:getUser(Data.CurrentPinging).mentionString}
			        
           	
			        for i, v in pairs(WebHooks.Pingers) do
            		
            	        PostWebhook(Data, v)
		
	    		    end
			
                end)()
            end
        end
    end)()

end