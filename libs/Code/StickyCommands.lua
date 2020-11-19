return function(Data)

    local Handler = Data.CommandHandler
    local Base = require("Code/Save"):GetDatabase("botinfo")
    local Client = Data.Client

    local Stickies = Base:GetAsync("Stickies")

    function Write()
        Base:PostAsync("Stickies", Stickies)
    end

    Client:on("messageCreate", function(MSG)
        

        if MSG.author.id == Client.user.id then return end

        if Stickies[MSG.channel.id] then

            local Channel = Client:getChannel(MSG.channel.id)
            local Last = Channel:getMessage(Stickies[MSG.channel.id].LastMessage)
            if Last then
                Last:delete()
            else
                print("no last")
            end

            if Stickies[MSG.channel.id].Enabled == true then



                local Sticky = Stickies[MSG.channel.id]

                local Send = MSG:reply({embed = {

                    title = Sticky.Title,
                    description = Sticky.Desc,
                    fields = Sticky.Fields

                }})

                if Send then
                    Stickies[MSG.channel.id].LastMessage = Send.id
                end

            end
        end

        Base:PostAsync("Stickies", Stickies)
    
    end)

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
        local ToEnable

        if Args[1] == "on" then
            ToEnable = true
            MSG:reply("Sticky is enabled!")
        elseif Args[1] == "off" then
            ToEnable = false
            MSG:reply("Sticky is enabled!")
        else
            MSG:reply("on or off")
            return
        end        
    
        if Stickies[MSG.channel.id] then
            Stickies[MSG.channel.id].Enabled = ToEnable
        else
            Stickies[MSG.channel.id] = {}
            Stickies[MSG.channel.id].Enabled = ToEnable
        end

        Write()

    end)

    local TitleCommand = Handler.New()
    TitleCommand:SetName("Stickytitle")
    TitleCommand:SetMinPerm("Owner")

    local NewTitle = TitleCommand:NewArg()
    NewTitle:SetName("New Title")
    NewTitle:SetType("String")
    NewTitle:SetReq(true)

    TitleCommand:SetFunction(function(MSG, Args, Raw)
        
        if Stickies[MSG.channel.id] then
            Stickies[MSG.channel.id].Title = table.concat(Raw, " ")
        else
            Stickies[MSG.channel.id] = {Fields = {}}
            Stickies[MSG.channel.id].Title = table.concat(Raw, " ")
        end

        MSG:reply("Title set!")

        Write()

    end)

    local DescCommand = Handler.New()
    DescCommand:SetName("Stickydesc")
    DescCommand:SetMinPerm("Owner")

    local NewDesc = DescCommand:NewArg()
    NewDesc:SetName("New Desc")
    NewDesc:SetType("String")
    NewDesc:SetReq(true)

    DescCommand:SetFunction(function(MSG, Args, Raw)
        
        if Stickies[MSG.channel.id] then
            Stickies[MSG.channel.id].Desc = table.concat(Raw, " ")
        else
            Stickies[MSG.channel.id] = {Fields = {}}
            Stickies[MSG.channel.id].Desc = table.concat(Raw, " ")
        end

        MSG:reply("Desc set to: " .. table.concat(Raw, " "))

        Write()

    end)

    local FieldTitleCommand = Handler.New()
    FieldTitleCommand:SetName("FieldTitle")
    FieldTitleCommand:SetMinPerm("Owner")

    local FieldNumber = FieldTitleCommand:NewArg()
    FieldNumber:SetName("NumberID")
    FieldNumber:SetType("Number")
    FieldNumber:SetReq(true)

    local FieldTitle = FieldTitleCommand:NewArg()
    FieldTitle:SetName("New-title")
    FieldTitle:SetType("String")
    FieldTitle:SetReq(false)

    FieldTitleCommand:SetFunction(function(MSG, Args, Raw)

        print(type(Args[1]))
        
        if Stickies[MSG.channel.id] then
            Stickies[MSG.channel.id].Fields = {}
            Stickies[MSG.channel.id].Fields[Args[1]] = {}
            Stickies[MSG.channel.id].Fields[Args[1]].name = table.concat(Raw, " ")
        else
            Stickies[MSG.channel.id] = {}
            Stickies[MSG.channel.id].Fields[Args[1]].name = table.concat(Raw, " ")
        end

        MSG:reply("Desc set to: " .. table.concat(Raw, " "))

        Write()

    end)






end