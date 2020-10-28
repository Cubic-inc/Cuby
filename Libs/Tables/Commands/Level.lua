return function(Data)
    local DataBase = Data.ShardData.Libs.Code.Save:GetDatabase("Levels")
    local CalcLevel = Data.ShardData.Libs.Code.CalcLevel
    
    local CurrentXp = DataBase:GetAsync(Data.Author.id) or 0
    local CurrentLevel = CalcLevel(CurrentXp)

    Data.PreMSG:setContent(Data.Author.mentionString .. " jij bent level **" .. CurrentLevel .. "**!\nJe hebt ook " .. CurrentXp .. " XP!")
    

end