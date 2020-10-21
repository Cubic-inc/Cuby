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



        local ToSend = {
            content = "",
            embeds = {
            {
                title = "User Warn",
                
                
                fields = {

                    {name = "**Moderator**", value = "`" .. Moderator.tag .. "`", inline = true},
                    {name = "**Overtreder**", value = "`" .. Member.tag .. "`", inline = true},
                    {name = "**Rede**", value = "`" .. Reason .. "`", inline = true},
                    {name = "**Tijd**", value = "`" .. os.date("%c") .. "`", inline = true},
                    {name = "**Link**", value = "[Message](" .. MSG.link .. ")", inline = true},

                },


                color = 0xff7e00
            }
        }}



        require("./PostWebhook.lua")(ToSend, require("../Tables/WebHooks.lua").Logger)
    else
        MSG:setContent("Specificeer een user")
    end

end