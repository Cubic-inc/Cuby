return function(Data)
    local Client = Data.Client
    local Prefix = Data.Prefix
    local Wait = Data.Libs.Code.Wait
    local Commands = Data.Libs.Tables.Commands
    local WebHooks = Data.Libs.Tables.WebHooks
    local Coro = require("coro-http")
    local Json = require("json")
    local LoggerLink = WebHooks.Logger

    

    Client:on("warning", function(MSG)
        local TimeTable = os.date("*t")
        local TimeString = os.date("%c")
		
		
        local Embed = {{

            title = "Error!",
            description = "",
         
            fields = {
                {name = "Message", value = MSG .. "\n"},
                {name = " ⠀ ", value = " ⠀ "},
				{name = "Time", value = TimeString},
				{name = " ⠀ ", value = " ⠀ "},
            },
         
            footer = {
                text = "Cuby - For the discord server",
            },
         
            timestamp = TimeString,

            color = require("discordia").Color.fromRGB(252, 0, 0).value,
         
         
         }}
        local Send = {content = "Warning", embeds = Embed}
        local Encode = Json.stringify(Send)
        --print(Encode)
        coroutine.wrap(function()
            local res, data = Coro.request("POST", LoggerLink, {{"Content-Type", "application/json"}}, Encode)
        end)()
        --print(res)
        --print(data)
    end)
	
	Client:on("error", function(MSG)
        local TimeTable = os.date("*t")
        local TimeString = os.date("%c")
		
		print(TimeString)
		
        local Embed = {{

            title = "Error!",
            description = "",
         
            fields = {
                {name = "Message", value = MSG .. "\n"},
                {name = " ⠀ ", value = " ⠀ "},
				{name = "Time", value = TimeString},
				{name = " ⠀ ", value = " ⠀ "},
            },
         
            footer = {
                text = "Cuby - For the discord server",
            },
         
            timestamp = TimeString,

            color = require("discordia").Color.fromRGB(252, 0, 0).value,
         
         
         }}
        local Send = {content = "error", embeds = Embed}
        local Encode = Json.stringify(Send)
        --print(Encode)
        coroutine.wrap(function()
            local res, data = Coro.request("POST", LoggerLink, {{"Content-Type", "application/json"}}, Encode)
        end)()
        --print(res)
        --print(data)
    end)
	

    --Wait(3)
    --Client:emit("warning", "test")
end