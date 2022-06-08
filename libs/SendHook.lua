local function GetTheHook(Channel)
    local Found = false
    local Webhook = nil

    local AllWebhooks = Channel.guild:getWebhooks()

    for i, v in pairs(AllWebhooks) do 
        if v.channelId == Channel.id and v.name == "CHANNELHOOK" then
            Found = true
            Webhook = v
            break
        end
    end

    if Found == true then
        return Webhook
    else
        print("No webhook found, creating one!")
        return Channel:createWebhook("CHANNELHOOK")
    end
end

return function (Channel, Data)
    local Hook = GetTheHook(Channel)

    local Link = Format("https://discord.com/api/webhooks/%s/%s", Hook.id, Hook.token)

    local Res, Body
    local Json = require("json")
    local StringData = Json.stringify(Data)
    local Coro = require("coro-http")

    pcall(function ()
        Res, Body = Coro.request("POST", Link, {{"Content-Type", "application/json"}}, StringData)
    end)


    return Res, Body
end