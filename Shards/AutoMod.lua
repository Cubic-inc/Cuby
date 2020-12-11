return function(Data)

    local XpMsgAdd = 10
    local CalcLevel = Data.Libs.Code.CalcLevel
    local ModClient = _G.ModClient

    local API = require("API")

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
                MSG.channel:send("Well done! " .. MSG.author.mentionString .. ", you are now level **" .. NewLevel .. "**!")
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
            API:CreateWarn(MSG.channel, MSG.author, Data.Client.user, "Repeating messages")
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
            API:CreateWarn(MSG.channel, MSG.author, Data.Client.user, "Swearing")
            MSG:delete()
        end

    end)




    local Handler = Data.CommandHandler

    local WarnCommand = Handler.New()

    WarnCommand:SetName("Warn")
    WarnCommand:SetMinPerm("Mod")
    WarnCommand:SetGroup("Moderation")
    
    local Arg = WarnCommand:NewArg()

    Arg:SetName("Member")
    Arg:SetType("Member")
    Arg:SetReq(true)

    local ReasonArg = WarnCommand:NewArg()

    ReasonArg:SetName("Rede")
    ReasonArg:SetType("String")
    ReasonArg:SetReq(false)

    WarnCommand:SetFunction(function(MSG, Args, Raw)
    
        local API = require("API")

        if Args[1].id == MSG.author.id then
            MSG:reply("You cant warn yourself!\nYou idot <:barf:772444449007206440>")
            return
        end

        table.remove(Raw, 1)

        local Reason

        if Raw[1] then
            Reason = table.concat(Raw, " ")
        end

        API:CreateWarn(MSG.channel, Args[1], MSG.author, Reason)

    end)

    local WarnListCommand = Handler.New()

    WarnListCommand:SetName("Warnlist")
    WarnListCommand:SetMinPerm("Mod")
    WarnListCommand:SetGroup("Moderation")
    
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
        local MSG = ModClient:getChannel(MSG.channel.id):getMessage(MSG.id)

        local WarnData = API:GetAllWarns(Args[1])

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
    WarnAmountCommand:SetGroup("Moderation")
    
    local MemberArg = WarnAmountCommand:NewArg()

    MemberArg:SetName("Member")
    MemberArg:SetType("Member")
    MemberArg:SetReq(true)

    WarnAmountCommand:SetFunction(function(MSG, Args, Raw)
        local WarnData = API:GetAllWarns(Args[1])
        local MSG = ModClient:getChannel(MSG.channel.id):getMessage(MSG.id)

        local Embed = {
            title = Args[1].name .. " Has:",

            description = tostring(#WarnData) .. " Warnigns",

        }

        MSG:reply({content = "", embed = Embed})
    
    end)

    local ClearWarnCommand = Handler.New()

    ClearWarnCommand:SetName("warnclear")
    ClearWarnCommand:SetMinPerm("Admin")
    ClearWarnCommand:SetGroup("Moderation")
    
    local MemberArg = ClearWarnCommand:NewArg()

    MemberArg:SetName("Member")
    MemberArg:SetType("Member")
    MemberArg:SetReq(true)

    local IdArg = ClearWarnCommand:NewArg()
    IdArg:SetName("Id")

    ClearWarnCommand:SetFunction(function(MSG, Args, Raw)

        local MSG = ModClient:getChannel(MSG.channel.id):getMessage(MSG.id)

        local Base = require("Code/Save"):GetDatabase("warnings")
        local Embed

        if Args[2] then
            local Found = API:RemoveWarn(Args[2])
            if Found then
                Embed = {description = "That warn was removed!"}
            else
                Embed = {description = "That warn warn not found!"}
            end
        else
            local Found = API:ClearWarns(Args[1])
            Embed = {description = "All user warns removed!"}
        end
        
        MSG:reply({content = "", embed = Embed})
    end)

    local MuteCommand = Handler.New()

    MuteCommand:SetName("mute")
    MuteCommand:SetMinPerm("Mod")
    MuteCommand:SetGroup("Moderation")
    
    local MemberArg = MuteCommand:NewArg()

    MemberArg:SetName("Member")
    MemberArg:SetType("Member")
    MemberArg:SetReq(true)

    MuteCommand:SetFunction(function(MSG, Args, Raw)
        local MSG = ModClient:getChannel(MSG.channel.id):getMessage(MSG.id)

        local Member = Args[1]
        table.remove(Raw, 1)
                
        if Member:hasRole("765149108985266217") then
            API:UnMute(Args[1])
            MSG:reply({embed = {description = ":white_check_mark: **" .. Member.tag .. "** has been unmuted"}})
        else
            API:Mute(Args[1])
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
    LevelCommand:SetGroup("Info")
    
    LevelCommand:SetFunction(function(MSG, Args, Raw)

        local DataBase = require("Code/Save"):GetDatabase("Levels")
        local CalcLevel = require("Code/CalcLevel")
        
        local CurrentXp = DataBase:GetAsync(MSG.author.id) or 0
        local CurrentLevel = CalcLevel(CurrentXp)
    
        MSG:reply(MSG.author.mentionString .. " you are level **" .. CurrentLevel .. "**!\nen And you have " .. CurrentXp .. " XP! <a:partyblob:772444448307019777>")
        
    end)

    local MoneyCommand = Handler.New()

    MoneyCommand:SetName("money")
    MoneyCommand:SetMinPerm("User")
    MoneyCommand:SetGroup("Leveling")
    
    MoneyCommand:SetFunction(function(MSG, Args, Raw)

        local DataBase = require("Code/Save"):GetDatabase("money")
        
        local CurrentXp = DataBase:GetAsync(MSG.author.id) or 0
    
        MSG:reply(MSG.author.mentionString .. " you have " .. CurrentXp .. "$! <a:partyblob:772444448307019777>")
        
    end)

    local AddMoneyCommand = Handler.New()

    AddMoneyCommand:SetName("setmoney")
    AddMoneyCommand:SetMinPerm("Owner")
    AddMoneyCommand:SetGroup("Leveling")
    
    AddMoneyCommand:SetFunction(function(MSG, Args, Raw)

        local DataBase = require("Code/Save"):GetDatabase("money")
        
        local CurrentXp = DataBase:GetAsync(MSG.author.id) or 0
    
        MSG:reply(MSG.author.mentionString .. " you have " .. CurrentXp .. "$! <a:partyblob:772444448307019777>")
        
    end)



end