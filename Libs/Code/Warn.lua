return function(MSG, Channel, Member, Moderator, Reason, Data)

    if not MSG then 
        if not Channel then return end
        MSG = Channel:send("Loading")
    end

    Reason = Reason or "Geen Rede Gegeven "

    if Member then
        if Reason then
            

            local ToSend = {
                content = "",
                embed = {
                
                    
                    description = "**" .. Member.tag .. "** is gewarned | `" .. Reason .. "`",
    
    
                    color = 0xff7e00
                
            }}

            MSG:update(ToSend)
        end

        local Reason


        local ToSend = {
            content = "",
            embeds = {
            {
                title = "User Warn",
                
                
                fields = {

                    {name = "**Moderator**", value = "`" .. Moderator.tag .. "`", inline = true},
                    {name = "**Overtreder**", value = "`" .. Member.tag .. "`", inline = true},
                    {name = "**Rede**", value = "`" .. Reason .. "`", inline = true},
                    {name = "**Tijd**", value = "`" .. os.date("%c") .. "`", inline = true}

                },

                footer = {text = "[Message](" .. MSG.link .. ")"},

                color = 0xff7e00
            }
        }}



        Data.ShardData.Libs.Code.PostWebhook(ToSend, require("././Tables.WebHooks.lua"))
    else
        MSG:setContent("Specificeer een user")
    end

end