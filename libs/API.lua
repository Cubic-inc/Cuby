local Module = {}

local Client = _G.Client
local MusicClient = _G.MClient
local ModClient = _G.ModClient

function Module:CreateWarn(Channel, Member, Moderator, Reason)

    local Base = require("Code/Save"):GetDatabase("warnings")

    local Message = ModClient:getChannel(Channel.id):send("Loading warn")

    Reason = Reason or "No reason"

    local SaveId = math.random(1000000, 9999999)

    --print(SaveId)

    local ToSend = {
        content = "<@" .. Member.id .. ">",
        embed = {
            description = "**" .. Member.tag .. "** has been warned | `" .. Reason .. "` with id:  `" .. SaveId .. "`",
            color = 0xff7e00
    }}
    Message:update(ToSend)

    local WarnAmount = _G.Data.GlobalValues.HourWarnAmount
    local NowAmount = WarnAmount[Member.id] or 0
    WarnAmount[Member.id] = NowAmount + 1

    if WarnAmount[Member.id] == 5 then
        WarnAmount[Member.id] = 0
        Message.channel:send({embed = {title = "Auto Mute", description = "User has reached more than 5 warns in an hour!"}})
        
        coroutine.wrap(function()
            local Timer = require("timer")
            Timer.sleep(15*60*1000)
            require("API"):UnMute(ModClient:getMember(Member.id))
        end)()
    end

    local ToSend = {
        content = "",
        embeds = {
        {
            title = "User Warn",
            fields = {
                {name = "**Moderator**", value = "`" .. Moderator.tag .. "`", inline = true},
                {name = "**Offendant**", value = "`" .. Member.tag .. "`", inline = true},
                {name = "**Reason**", value = "`" .. Reason .. "`", inline = true},
                {name = "**Time**", value = "`" .. os.date("%c") .. "`", inline = true},
                {name = "**Link**", value = "[Message](" .. Message.link .. ")", inline = true},
            },
            color = 0xff7e00
        }
    }}

    local Query = require("querystring")

    local SaveData = {
        Id = SaveId,
        Overtreder = Member.id,
        Rede = Reason,
        Tijd = os.date("%c"),
        Moderator = Moderator.id,
        Link = Query.urlencode(Message.link)
    }

    Base:PostAsync(SaveId, SaveData)
    require("Code/PostWebhook")(ToSend, require("Tables/WebHooks").Logger)
end

function Module:GetWarn(ID)
    local ToReturn
    local Base = require("Code/Save"):GetDatabase("warnings")
    ToReturn = Base:GetAsync(ID)
    return ToReturn
end

function Module:GetAllWarns(User)
    local ToReturn = {}


    local Base = require("Code/Save"):GetDatabase("warnings")
    local AllAll = Base:GetStoreAsync()

    for i, v in pairs(AllAll) do
        if v.Overtreder == User.id then
            table.insert(ToReturn, v)
        end
    end


    return ToReturn
end

function Module:RemoveWarn(Id)
    local Base = require("Code/Save"):GetDatabase("warnings")
    local ToReturn = false
    local Warn = Base:GetAsync(Id)
    if Warn then ToReturn = true end
    Base:PostAsync(Id, nil)
    return ToReturn
end

function Module:ClearWarns(User)
    local API = require("API")
    local Base = require("Code/Save"):GetDatabase("warnings")
    local All = API:GetAllWarns(User)

    for i, v in pairs(All) do 
        Base:PostAsync(v.Id, nil)
    end
end

function Module:Sudo(User, Channel, Text)
    local API = require("API")

    local Webhook = API:GetChannelWebhook(Channel)

    local Data = {
        content = Text,
        username = User.name,
        avatar_url = User.user.avatarURL
    }

    require("Code/PostWebhook")(Data, "https://discord.com/api/webhooks/" .. Webhook.id .. "/" .. Webhook.token)
end

function Module:GetChannelWebhook(Channel)
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

function Module:Mute(Member, Channel)
    if not Channel then
        Member:addRole("765149108985266217")
        return
    end

    local Base = require("Code/Save"):GetDatabase("mutes")

    Base:PostAsync(Member.id, {

        Member = Member.id,
        Channel = Channel.id

    })
end

function Module:UnMute(Member, Channel)
    if not Channel then
        Member:removeRole("765149108985266217")
        return
    end

    local Base = require("Code/Save"):GetDatabase("mutes")

    Base:PostAsync(Member.id, nil)
end

function Module:GetAuth(Parms)

    local Http = require("coro-http")
    local Query = require("querystring")
    local Json = require("json")
    local Res, Body = Http.request("POST", "https://discord.com/api/oauth2/token/", {{"Content-Type", "application/x-www-form-urlencoded"}}, Query.stringify(Parms))
    return Json.decode(Body)

end

function Module:GetToken(Token)
    return require("../Tokens.lua")[Token] or os.getenv(string.upper(Token))
end

return Module