return function(Data)

    local Handler = Data.CommandHandler
    local Base = require("Code/Save"):GetDatabase("botinfo")

    --Base:PostAsync("Stickies", {})

    function PostSticky(Channel)

        local Stickies = Base:GetAsync("Stickies")
        if Stickies[Channel.id] then
            local Sticky = Stickies[Channel.id]

            local Last = Channel:getMessage(Sticky.LastId)
            if Last then Last:delete() end

            if Sticky.Embed then

                Channel:send({embed = Sticky.Embed})

            end
        end

    end

    local EnableCommand = Handler.New()
    EnableCommand:SetName("EnableSticky")
    EnableCommand:SetMinPerm("Owner")

    local BoolEnable = EnableCommand:NewArg()
    BoolEnable:SetName("Status")
    BoolEnable:SetType("String")
    BoolEnable:SetReq(true)

    EnableCommand:SetFunction(function(MSG, Args, Raw)

        

        if Args[i] == "on" then
            local BoolEnable = true
        elseif Args[i] == "off" then
            local BoolEnable = false
        else
            MSG:reply("aan of uit?")
            return
        end
    
        local Stickies = Base:GetAsync("Stickies")
        if Stickies[MSG.channel.id] then
            local Sticky = Stickies[MSG.channel.id]
        else
            Stickies[MSG.channel.id] = {}
            local Sticky = Stickies[MSG.channel.id]
        end

    end)






end