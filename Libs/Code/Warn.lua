return function(MSG, Channel, Member, Moderator, Reason, Data)

    local Base = require("./Save.lua"):GetDatabase("warnings")


    if not MSG then 
        if not Channel then return end
        MSG = Channel:send("Loading")
    end

    Reason = Reason or "Geen Rede Gegeven "

    if Member then
        if Reason then
            

            local ToSend = {
                content = "",
                embed = {
                
                    
                    description = "**" .. Member.tag .. "** is gewarned | `" .. Reason .. "`",
    
    
                    color = 0xff7e00
                
            }}

            MSG:update(ToSend)
        end



        local ToSend = {
            content = "",
            embeds = {
            {
                title = "User Warn",
                
                
                fields = {

                    {name = "**Moderator**", value = "`" .. Moderator.tag .. "`", inline = true},
                    {name = "**Overtreder**", value = "`" .. Member.tag .. "`", inline = true},
                    {name = "**Rede**", value = "`" .. Reason .. "`", inline = true},
                    {name = "**Tijd**", value = "`" .. os.date("%c") .. "`", inline = true},
                    {name = "**Link**", value = "[Message](" .. MSG.link .. ")", inline = true},

                },


                color = 0xff7e00
            }
        }}

        local OlderWarns = Base:GetAsync(Member.id) or {}

        local HighestId = 1

        for i, v in pairs(OlderWarns) do
            if v.Id > HighestId then
                HighestId = v.Id
            end
        end

        local Query = require("querystring")

        local SaveData = {
            Id = HighestId + 1,
            Overtreder = Member.id,
            Rede = Reason,
            Tijd = os.date("%c"),
            Moderator = Moderator.id,
            Link = Query.urlencode(MSG.link)
        }


        if #OlderWarns ~= 0 then
            OlderWarns[HighestId + 1] = SaveData
            SaveData.Id = HighestId + 1
        else
            OlderWarns[HighestId] = SaveData
            SaveData.Id = HighestId
        end
        --table.insert(OlderWarns, SaveData.Id, SaveData)

        --coroutine.wrap(function()
            Base:PostAsync(Member.id, OlderWarns)
        --end)()


        require("./PostWebhook.lua")(ToSend, require("../Tables/WebHooks.lua").Logger)
    else
        MSG:setContent("Specificeer een user")
    end

end