return function(Data)
    local MentionedArray = Data.OrgMSG.mentionedUsers:toArray()

    if MentionedArray[1] then
        if Data.Args[1] then
            

            local ToSend = {
                content = "",
                embed = {
                
                    
                    description = "**" .. MentionedArray[1].tag .. "** is gewarned | `" .. table.concat(Data.Args, " ") .. "`",
    
    
                    color = 0xff7e00
                
            }}

            Data.PreMSG:update(ToSend)
            
        else
            

            local ToSend = {
                content = "",
                embed = {
                
                    
                    description = "**" .. MentionedArray[1].tag .. "** is gewarned | `Geen Rede Gegeven `",
    
    
                    color = 0xff7e00
                
            }}

            Data.PreMSG:update(ToSend)
        end

        local Reason = table.concat(Data.Args, " ") or "Geen Rede"

        local ToSend = {
            content = "",
            embeds = {
            {
                title = "User Warn",
                
                description = "**Moderator** | `" .. Data.Author.tag .. "`\n**Overtreder** | `" .. MentionedArray[1].tag .. "`\n**Rede** | `" .. Reason .. "`\n**Time** | `" .. os.date("%c") .. "`",


                color = 0xff7e00
            }
        }}



        Data.ShardData.Libs.Code.PostWebhook(ToSend, Data.ShardData.Libs.Tables.WebHooks.Logger)
    else
        Data.PreMSG:setContent("Specificeer een user")
    end
end