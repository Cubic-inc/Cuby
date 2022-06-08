return function ()
    local DataBase = require("Save"):GetDatabase("Levels")
    local XpMsgAdd = 10
    local LastMSGs = _G.LastMSGs

    Client:on("messageCreate", function(MSG)
        if MSG.channel.id == "685066367526895658" or MSG.channel.id == "759717939631882280" or MSG.channel.id == "758701430642311188" then return end
        if MSG.author.bot then return end
				if not MSG.guild then return end
        
        local CurrentXp = DataBase:GetAsync(MSG.author.id) or 0
        local CurrentLevel = CalcLevel(CurrentXp)

        if not LastMSGs[MSG.author.id] then return end

        if LastMSGs[MSG.author.id].Content ~= MSG.content then

            local NewXp = CurrentXp + XpMsgAdd
            local NewLevel = CalcLevel(NewXp)

            DataBase:PostAsync(MSG.author.id, NewXp)
            
            if NewLevel ~= CurrentLevel then
                MSG.channel:send("Well done! " .. MSG.author.mentionString .. ", you are now level **" .. NewLevel .. "**! +500$")
                local MoneyBase = require("Save"):GetDatabase("Money")

                MoneyBase:PostAsync(MSG.author.id, MoneyBase:GetAsync(MSG.author.id) or 0 + 500)
            end
        end
    end)
end