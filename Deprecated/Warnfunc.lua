return function(MSG, Channel, Member, Moderator, Reason, Data)

    local Base = require("./Save.lua"):GetDatabase("warnings")
    local ModClient = _G.ModClient

    if not MSG then 
        if not Channel then return end
        MSG = ModClient:getChannel(Channel.id):send("Loading")
    end

    Reason = Reason or "No reason"

    if Member then
        if Reason then
            

            local ToSend = {
                content = "",
                embed = {
                
                    
                    description = "**" .. Member.tag .. "** has been warned | `" .. Reason .. "`",
    
    
                    color = 0xff7e00
                
            }}

            MSG:update(ToSend)
        end

        --print(-1)
        local WarnAmount = _G.Data.GlobalValues.HourWarnAmount
        --print(-2)
        local NowAmount = WarnAmount[Member.id] or 0
        --print(1)

        WarnAmount[Member.id] = NowAmount + 1
        --print(2)
        print(WarnAmount[Member.id])
        --print(3)

        if WarnAmount[Member.id] == 5 then
            WarnAmount[Member.id] = 0
            MSG.channel:send({embed = {title = "Auto Mute", description = "User has reached more than 5 warns in an hour!"}})
            MSG.channel.client:getGuild("657227821047087105"):getMember(Member.id):addRole("765149108985266217")
            coroutine.wrap(function()
                local Timer = require("timer")
                Timer.sleep(15*60*1000)
                MSG.channel.client:getGuild("657227821047087105"):getMember(Member.id):removeRole("765149108985266217")
            end)()
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
        MSG:setContent("Ping a user")
    end

end