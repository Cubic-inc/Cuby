local Module = {}

local Client = _G.Client
local Save = require("Save")
local Base = Save:GetDatabase("warnings")
local Query = require("querystring")

function Module.Create (Channel, Member, Reason)

    Reason = Reason or "No reason"
    local SaveId = math.random(1000000, 9999999)

    local ToSend = {
        content = "<@" .. Member.id .. ">",
        embed = {
            description = Format("Warned **`%s`**\nWith Reason: **`%s`**\nWith id: **`%s`**", Member.tag, Reason, SaveId),
            color = 0xff7e00
    }}
    local Message = Channel:send(ToSend)

    local LogTitle = "User Warn"
    local LogFields = {
        {name = "**Offendant**", value = "`" .. Member.tag .. "`", inline = true},
        {name = "**Reason**", value = "`" .. Reason .. "`", inline = true},
        {name = "**Link**", value = "[Message](" .. Message.link .. ")", inline = true},
    }
    
    require("Log")(LogTitle, LogFields, 0xff7e00)

    local SaveData = {
        Id = SaveId,
        Offendant = Member.id,
        Reason = Reason,
        Link = Query.urlencode(Message.link)
    }

    Base:PostAsync(SaveId, SaveData)
end

function Module.Get (Id)
    local ToReturn = Base:GetAsync(Id)
    return ToReturn
end

function Module.GetUserWarns (User)
    local ToReturn = {}

    local AllAll = Base:GetStoreAsync()

    for i, v in pairs(AllAll) do
        if v.Offendant == User.id then
            table.insert(ToReturn, v)
        end
    end

    return ToReturn
end

function Module.RemoveWarn(Id)
    local ToReturn = false
    local Warn = Base:GetAsync(Id)
    if Warn then ToReturn = true end
    Base:PostAsync(Id, nil)
    return ToReturn
end

function Module.ClearWarns(User)
    local WarnModule = require("Warn")
    local All = WarnModule.GetUserWarns(User)

    for i, v in pairs(All) do 
        Base:PostAsync(v.Id, nil)
    end
end

return Module