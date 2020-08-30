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
        local TimeString = TimeTable.year .. "-" .. TimeTable.month .. "-" .. TimeTable.day .. " " .. TimeTable.hour .. ":" .. TimeTable.min
        local Embed = {

            title = "Warning!",
            description = "",
         
            fields = {
                {name = "Message", value = MSG},
                {name = "TimeStamp", value = TimeString},
            },
         
            footer = {
                text = "Cuby - For the discord server",
            },
         
            color = require("discordia").Color.fromRGB(126, 211, 33).value,
         
         
         }
        local Send = {["content"] = "Warning", ["embed"] = Embed}
        local Encode = Json.stringify(Send)
        print(Encode)
        coroutine.wrap(function()
            local res, data = Coro.request("POST", LoggerLink, Encode)
        end)()
        print(res)
        print(data)
    end)

    Wait(3)
    Client:emit("warning", "test")
end