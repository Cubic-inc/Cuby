return function(Data)
    local MentionedArray = Data.OrgMSG.mentionedUsers:toArray()

    if MentionedArray[1] then
        if Data.Args[1] then
            Data.PreMSG:setContent("**" .. MentionedArray[1].tag .. "** is gewarned: " .. Data.Args[1])
        else
            Data.PreMSG:setContent("**" .. MentionedArray[1].tag .. "** is gewarned: Geen Rede Gegeven")
        end



        local ToSend = {
            content = "",
            embeds = {
            {
                title = "User Warn",
                
                
                fields = {
                
                    {name = " ⠀ ", value = " Moderator: "},
                    {name = Data.Author.tag, value = " ⠀ "},
                    {name = " ⠀ ", value = " Offender: "},
                    {name = MentionedArray[1].tag, value = " ⠀ "},
                    {name = " ⠀ ", value = " Reason: "},
                    {name = Data.Args[1] or "Geen Rede", value = " ⠀ "},
                    {name = " ⠀ ", value = " Time: "},
                    {name = os.date("%c"), value = " ⠀ "},
                
                },
                
                color = 0xff7e00
            }
        }}

        Data.ShardData.Libs.Code.PostWebhook(ToSend, Data.ShardData.Libs.Tables.WebHooks.Logger)
    else
        Data.PreMSG:setContent("Specificeer een user")
    end
end