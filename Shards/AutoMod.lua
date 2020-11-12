return function(Data)

    local XpMsgAdd = 10
    local CalcLevel = Data.Libs.Code.CalcLevel

    --685066367526895658
    --759717939631882280

    local DataBase = Data.Libs.Code.Save:GetDatabase("Levels")
    local LastMSGs = {}

    Data.Client:on("messageCreate", function(MSG)
        if MSG.channel.id == "685066367526895658" or MSG.channel.id == "759717939631882280" or MSG.channel.id == "758701430642311188" then --[[print("Channel ignored")]] return end
        if MSG.author.bot then --[[print("no bot users")]] return end
        
        local CurrentXp = DataBase:GetAsync(MSG.author.id) or 0
        local CurrentLevel = CalcLevel(CurrentXp)
        --print(CurrentLevel)
        --print(CurrentXp)

        if not LastMSGs[MSG.author.id] then return end

        if LastMSGs[MSG.author.id].Content ~= MSG.content then

            local NewXp = CurrentXp + XpMsgAdd
            local NewLevel = CalcLevel(NewXp)
            --print(NewLevel)
            --print(NewXp)

            DataBase:PostAsync(MSG.author.id, NewXp)
            

            --print(MSG.author.name)

            if NewLevel ~= CurrentLevel then
                MSG.channel:send("Well done " .. MSG.author.mentionString .. " you are now level**" .. NewLevel .. "**!")
            end
            --print("good")
        else
            --print("not good")
        end
        --print(LastMSGs[MSG.author.id].Content)
        --print(MSG.content)
    end)

    

    Data.Client:on("messageCreate", function(MSG)
        if MSG.channel.id == "685066367526895658" or MSG.channel.id == "759717939631882280" or MSG.channel.id == "758701430642311188" or MSG.channel.id == "775694351141175306" then --[[print("Channel ignored")]] return end
        if MSG.author.bot then --[[print("no bot users")]] return end

        Data.Libs.Code.Wait(200)
        
        if not LastMSGs[MSG.author.id] then
            LastMSGs[MSG.author.id] = {Content = "", Times = 0}
        end
        
        

        if LastMSGs[MSG.author.id].Content == MSG.content then
            MSG:delete()
            LastMSGs[MSG.author.id] = {Content = MSG.content, Times = LastMSGs[MSG.author.id].Times + 1}
            
        else
            LastMSGs[MSG.author.id].Times = 0
        end

        if LastMSGs[MSG.author.id].Times >= 3 then
            Data.Libs.Code.Warn(nil, MSG.channel, MSG.author, Data.Client.user, "Berichten herhalen")
        end

        LastMSGs[MSG.author.id].Content = MSG.content
        --print(LastMSGs[MSG.author.id].Times)
    end)

    local SwearWords = {
        "rko",
        "kanker",
        "tering",
        "klootzak",
        "kutwijf",
        "kuttenkop",
        "loser",
        "lummel",
        "lul",
        "piemel",
        "kaashoer",
        "hoer",
        "mongool",
        "klootviool",
        "eikel",
        "kankerhoer",
        "kankerhond",
        "kankerlijder",
        "kankerlijer",
        "kankernicht",
        "kapsoneslijer",
        "mietje",
        "bitch",
        "kutwijf",
        "kutvent",
        "kontkruiper",
        "kontneuker",
        "https://cdn.discordapp.com/attachments/768526368173981707/769643539683999764/image0.jpg"

    }



    Data.Client:on("messageCreate", function(MSG)
        if MSG.author.bot then --[[print("no bot users")]] return end
        
        local Found = false

        for i, v in pairs(SwearWords) do
            if string.find(string.lower(MSG.content), v) then
                Found = true
                break
            end
        end


        if Found == true then
            Data.Libs.Code.Warn(nil, MSG.channel, MSG.author, Data.Client.user, "Schelden")
            MSG:delete()
        end

    end)




    local Handler = Data.CommandHandler

    local WarnCommand = Handler.New()

    WarnCommand:SetName("Warn")
    WarnCommand:SetMinPerm("Mod")
    
    local Arg = WarnCommand:NewArg()

    Arg:SetName("Member")
    Arg:SetType("Member")
    Arg:SetReq(true)

    local ReasonArg = WarnCommand:NewArg()

    ReasonArg:SetName("Rede")
    ReasonArg:SetType("String")
    ReasonArg:SetReq(false)

    WarnCommand:SetFunction(function(MSG, Args, Raw)
    
        local WarnFunction = require("Code/Warn")

        if Args[1].id == MSG.author.id then
            MSG:reply("You cant warn yourself!\nYou idot <:barf:772444449007206440>")
            return
        end

        table.remove(Raw, 1)

        local Reason

        if Raw[1] then

            Reason = table.concat(Raw, " ")

        end



        WarnFunction(nil, MSG.channel, Args[1], MSG.author, Reason)

    end)

    local WarnListCommand = Handler.New()

    WarnListCommand:SetName("Warnlist")
    WarnListCommand:SetMinPerm("Mod")
    
    local MemberArg = WarnListCommand:NewArg()

    MemberArg:SetName("Member")
    MemberArg:SetType("Member")
    MemberArg:SetReq(true)

    local BeginArg = WarnListCommand:NewArg()

    BeginArg:SetName("From")
    BeginArg:SetType("String")
    BeginArg:SetReq(false)

    local EndArg = WarnListCommand:NewArg()

    EndArg:SetName("To")
    EndArg:SetType("String")
    EndArg:SetReq(false)

    WarnListCommand:SetFunction(function(MSG, Args, Raw)
        local Base = require("Code/Save"):GetDatabase("warnings")
        local WarnData = Base:GetAsync(Args[1].id) or {}

        local Embed = {
            title = Args[1].name .. "'s Warnings",

            fields = {}
        }

        local Query = require("querystring")
        for i, v in pairs(WarnData) do
            local Field = {
                name = "**Warning id: " .. v.Id .. "**",
                value = "Moderator: `" .._G.Data.Client:getUser(v.Moderator).tag .. "`\nReason: `" .. v.Rede .. "`\nTime: `" .. v.Tijd .. "`\nLink: [Message](" .. Query.urldecode(v.Link) .. ")",
                inline = true
            }
            table.insert(Embed.fields, Field)
        end
        
        MSG:reply({content = "", embed = Embed})
    end)

    local WarnAmountCommand = Handler.New()

    WarnAmountCommand:SetName("warnamount")
    WarnAmountCommand:SetMinPerm("Mod")
    
    local MemberArg = WarnAmountCommand:NewArg()

    MemberArg:SetName("Member")
    MemberArg:SetType("Member")
    MemberArg:SetReq(true)

    WarnAmountCommand:SetFunction(function(MSG, Args, Raw)
        local Base = require("Code/Save"):GetDatabase("warnings")
        local WarnData = Base:GetAsync(Args[1].id) or {}

        local Embed = {
            title = Args[1].name .. " Has:",

            description = tostring(#WarnData) .. " Warnigns",

        }

        MSG:reply({content = "", embed = Embed})
    
    end)

    local ClearWarnCommand = Handler.New()

    ClearWarnCommand:SetName("warnclear")
    ClearWarnCommand:SetMinPerm("Admin")
    
    local MemberArg = ClearWarnCommand:NewArg()

    MemberArg:SetName("Member")
    MemberArg:SetType("Member")
    MemberArg:SetReq(true)

    ClearWarnCommand:SetFunction(function(MSG, Args, Raw)

        if Args[1].id == MSG.author.id then
            MSG:reply("Can't remove your own warnings! <:gay:772443615402131456>")
            return
        end

        local Base = require("Code/Save"):GetDatabase("warnings")
        local Embed = {
            description = "**" .. Args[1].tag .. "** have been removed",
        }

        --print("clear")
        
        MSG:reply({content = "", embed = Embed})
        --print(Base:PostAsync(Args[1].id, nil))

        --print("tstets")
        --print("done")
    
    end)

    local MuteCommand = Handler.New()

    MuteCommand:SetName("mute")
    MuteCommand:SetMinPerm("Mod")
    
    local MemberArg = MuteCommand:NewArg()

    MemberArg:SetName("Member")
    MemberArg:SetType("Member")
    MemberArg:SetReq(true)

    MuteCommand:SetFunction(function(MSG, Args, Raw)

        local Member = Args[1]
        table.remove(Raw, 1)
                
        if Member:hasRole("765149108985266217") then
            Member:removeRole("765149108985266217")
            MSG:reply({description = ":white_check_mark: **" .. Member.tag .. "** Is now unmuted"})
        else
            Member:addRole("765149108985266217")
            if Raw[1] then
                MSG:reply({content = "", embed = {description = ":white_check_mark: **" .. Member.tag .. "** Is now muted | " .. table.concat(Raw, " ")}})
            else
                MSG:reply({content = "", embed = {description = ":white_check_mark: **" .. Member.tag .. "** Is now muted | " .. "No reason"}})
            end
        end
    
    end)

    local LevelCommand = Handler.New()

    LevelCommand:SetName("level")
    LevelCommand:SetMinPerm("User")
    
    LevelCommand:SetFunction(function(MSG, Args, Raw)

        local DataBase = require("Code/Save"):GetDatabase("Levels")
        local CalcLevel = require("Code/CalcLevel")
        
        local CurrentXp = DataBase:GetAsync(MSG.author.id) or 0
        local CurrentLevel = CalcLevel(CurrentXp)
    
        MSG:reply(MSG.author.mentionString .. " you are level **" .. CurrentLevel .. "**!\nen And you have " .. CurrentXp .. " XP! <a:partyblob:772444448307019777>")
        
    end)



end