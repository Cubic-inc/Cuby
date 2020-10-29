return {
    Lock = function(Data)
        if Data.ShardData.GlobalValues.Channels[Data.Author.id] then
            Data.ShardData.GlobalValues.Channels[Data.Author.id].Locked = true
            Data.PreMSG:setContent("Je channel is nu **GELOCKED** (Gebruik !unlockchannel om ongedaan te maken)")
        else
            Data.PreMSG:setContent("Je hebt op het moment geen kanaal")
        end
    end,
    Unlock = function(Data)
        if Data.ShardData.GlobalValues.Channels[Data.Author.id] then
            Data.ShardData.GlobalValues.Channels[Data.Author.id].Locked = false
            Data.PreMSG:setContent("Je channel is nu **GEUNLOCKED** (Gebruik !lockchannel om ongedaan te maken)")
        else
            Data.PreMSG:setContent("Je hebt op het moment geen kanaal")
        end
    end,
    Addmember = function(Data)
        if Data.ShardData.GlobalValues.Channels[Data.Author.id] then
            Data.ShardData.GlobalValues.Channels[Data.Author.id].Locked = false
            Data.PreMSG:setContent("Je channel is nu **GEUNLOCKED** (Gebruik !lockchannel om ongedaan te maken)")
        else
            Data.PreMSG:setContent("Je hebt op het moment geen kanaal")
        end
        
    end

}