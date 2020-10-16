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
                
                    
                    description = ":white_check_mark: **" .. MentionedArray[1].tag .. "** is gewarned | `Geen Rede Gegeven `",
    
    
                    color = 0xff7e00
                
            }}

            Data.PreMSG:update(ToSend)
        end

        local Reason

        if Data.Args[1] then
            Reason = table.concat(Data.Args, " ")
        else
            Reason = "Geen Rede"
        end

        local ToSend = {
            content = "",
            embeds = {
            {
                title = "User Warn",
                
                
                fields = {

                    {name = "**Moderator**", value = "`" .. Data.Author.tag .. "`", inline = true},
                    {name = "**Overtreder**", value = "`" .. MentionedArray[1].tag .. "`", inline = true},
                    {name = "**Rede**", value = "`" .. Reason .. "`", inline = true},
                    {name = "**Tijd**", value = "`" .. os.date("%c") .. "`", inline = true}

                },

                color = 0xff7e00
            }
        }}



        Data.ShardData.Libs.Code.PostWebhook(ToSend, Data.ShardData.Libs.Tables.WebHooks.Logger)
    else
        Data.PreMSG:setContent("Specificeer een user")
    end
end