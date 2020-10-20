return function(Data)

    local XpMsgAdd = 10
    local CalcLevel = Data.Libs.Code.CalcLevel

    --685066367526895658
    --759717939631882280

    local DataBase = Data.Libs.Code.Save:GetDatabase("Levels")
    

    Data.Client:on("messageCreate", function(MSG)
        if MSG.channel.id == "685066367526895658" or MSG.channel.id == "759717939631882280" or MSG.channel.id == "758701430642311188" then print("Channel ignored") return end
        if MSG.author.bot then print("no bot users") return end
        
        local CurrentXp = DataBase:GetAsync(MSG.author.id) or 0
        local CurrentLevel = CalcLevel(CurrentXp)
        --print(CurrentLevel)
        --print(CurrentXp)

        local NewXp = CurrentXp + XpMsgAdd
        local NewLevel = CalcLevel(NewXp)
        --print(NewLevel)
        --print(NewXp)

        DataBase:PostAsync(MSG.author.id, NewXp)

        --print(MSG.author.name)

        if NewLevel ~= CurrentLevel then
            MSG.channel:send("Goed gedaan " .. MSG.author.mentionString .. " je bent nu level **" .. NewLevel .. "**!")
        end

    end)

end