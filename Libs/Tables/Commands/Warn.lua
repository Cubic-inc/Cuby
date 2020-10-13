return function(Data)
    local MentionedArray = Data.OrgMSG.mentionedUsers:toArray()

    if MentionedArray[1] then
        if Data.Args[1] then
            Data.PreMSG:setContent("**" .. MentionedArray[1].tag .. "** is gewarned: " .. Data.Args[1])
        else
            Data.PreMSG:setContent("**" .. MentionedArray[1].tag .. "** is gewarned: Geen Rede Gegeven")
        end

        local Reason = Data.Args[1] or "Geen Rede"

        local ToSend = {
            content = "",
            embeds = {
            {
                title = "User Warn",
                
                description = "**Moderator** | `" .. Data.Author.tag .. "`\n**Overtreder** | `" .. MentionedArray[1].tag .. "`\n**Rede** | " .. Reason .. "\n**Time** | `" .. os.date("%c") .. "`",


                color = 0xff7e00
            }
        }}

        Data.ShardData.Libs.Code.PostWebhook(ToSend, Data.ShardData.Libs.Tables.WebHooks.Logger)
    else
        Data.PreMSG:setContent("Specificeer een user")
    end
end