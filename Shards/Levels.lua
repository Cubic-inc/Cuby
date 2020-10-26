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
                MSG.channel:send("Goed gedaan " .. MSG.author.mentionString .. " je bent nu level **" .. NewLevel .. "**!")
            end
            --print("good")
        else
            --print("not good")
        end
        --print(LastMSGs[MSG.author.id].Content)
        --print(MSG.content)
    end)

    

    Data.Client:on("messageCreate", function(MSG)
        if MSG.channel.id == "685066367526895658" or MSG.channel.id == "759717939631882280" or MSG.channel.id == "758701430642311188" then --[[print("Channel ignored")]] return end
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
        "oen",
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
        "7",
        "zeven",
        "seven"

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

end