local Module = {}

local Save = require("Save")
local Guild = _G.Guild
local MuteRole = _G.MuteRole

local MuteStore = Save:GetDatabase("Mutes")
local LogModule = require("Log")

function Module.Mute(User, Reason, Channel, TimeInMins)
    local Member = Guild:getMember(User.id)
    Reason = Reason or "No reason"

    Member:addRole(MuteRole)

    local CurrentSec = _G.Date():toSeconds()

    local EndSec = CurrentSec + TimeInMins * 60

    local Data = {

        UserName = User.name,
        EndsAt = EndSec,

    }

    local Message = Channel:send({
        embed = {
            description = Format("Muted **`%s`** \nWith Reason: **`%s`** \nFor **`%s`** Minutes", User.tag, Reason, TimeInMins),
            color = 0xff7e00
        }
    })

    local LogFields = {
        {name = "**Offendant**", value = "`" .. Member.tag .. "`", inline = true},
        {name = "**Reason**", value = "`" .. Reason .. "`", inline = true},
        {name = "**Link**", value = "[Message](" .. Message.link .. ")", inline = true},
    }

    LogModule("User Mute", LogFields, 0xff7e00)
    MuteStore:PostAsync(User.id, Data)

end

function Module.UnMute(User, Channel)
    local Member = Guild:getMember(User.id)
    local Message
    if Channel then
        Message = Channel:send({
            embed = {
                description = Format("Unmuted **`%s`**", User.tag),
                color = 0xff7e00
            }
        })
    end

    local LogFields = {
        {name = "**Offendant**", value = "`" .. Member.tag .. "`", inline = true},
        --{name = "**Link**", value = "[Message](" .. tostring(Message.link) .. ")", inline = true},
    }

    LogModule("User Unmute", LogFields, 0xff7e00)

    Member:removeRole(MuteRole)
    MuteStore:PostAsync(User.id, nil)
end

function Module.Is(User)
    return User:hasRole(MuteRole)
end

return Module