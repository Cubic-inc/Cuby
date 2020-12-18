return function(Data)

    local Discordia = require("discordia")

    local Client = Data.Client
    local Prefix = Data.Prefix
    local Wait = Data.Libs.Code.Wait
	local TableToString = Data.Libs.Code.TableToString
    local Commands = Data.Libs.Tables.Commands
    local WebHooks = Data.Libs.Tables.WebHooks

    local PostWebhook = Data.Libs.Code.PostWebhook
	
    local Coro = require("coro-http")
    local Json = require("json")
    local LoggerLink = WebHooks.Logger

    local Blacklist = {["760402794066083871"] = true}

    Client:on("voiceChannelJoin", function(Member, Channel)
        
        --print("join")
        
        if Blacklist[Channel.id] then return end
        if Member.user.bot == true then return end
        if not Channel then return end
		
        local ToSend = {
            content = "",
            embeds = {
            {
                title = "Channel Join",

                --description = "**Channel** | `" .. Channel.name .. "`\n**Member** | `" .. Member.tag .. "`\n**Time** | `" .. os.date("%c") .. "`",
                
                fields = {

                    {name = "**Channel**", value = "`" .. Channel.name .. "`", inline = true},
                    {name = "**Member**", value = "`" .. Member.tag .. "`", inline = true},
                    {name = "**Time**", value = "`" .. os.date("%c") .. "`", inline = true}

                },
                
                color = 0x00FF00,
            }
        }}
		
        local one, two = PostWebhook(ToSend, LoggerLink)
        --print(one)
        --print(two)

    end)

    Client:on("voiceChannelLeave", function(Member, Channel)
        
        --print("Leave")
        
        if Blacklist[Channel.id] then return end
        if Member.user.bot == true then return end
        if not Channel then return end
		
        local ToSend = {
            content = "",
            embeds = {
            {
                title = "Channel Leave",
				
				--description = "**Channel** | `" .. Channel.name .. "`\n**Member** | `" .. Member.tag .. "`\n**Time** | `" .. os.date("%c") .. "`",
                
                fields = {

                    {name = "**Channel**", value = "`" .. Channel.name .. "`", inline = true},
                    {name = "**Member**", value = "`" .. Member.tag .. "`", inline = true},
                    {name = "**Time**", value = "`" .. os.date("%c") .. "`", inline = true}

                },

                color = 0xFF0000
            }
        }}
		
        local one, two = PostWebhook(ToSend, LoggerLink)
        --print(one)
        --print(two)

    end)

    Client:on("messageDelete", function(Message)

        if not Message then return end
        if Message.author.bot == true then return end
        

        local ToSend = {
            content = "",
            embeds = {
            {
                title = "Message Delete",
				
				--description = "**Text** | `" .. Message.cleanContent .. "`\n**Author** | `" .. Message.author.tag .. "`\n**Time** | `" .. os.date("%c") .. "`",
                
                fields = {

                    {name = "**Content**", value = "`" .. Message.cleanContent .. "`", inline = true},
                    {name = "**Member**", value = "`" .. Message.author.tag .. "`", inline = true},
                    {name = "**Time**", value = "`" .. os.date("%c") .. "`", inline = true}

                },
                
                color = 0xFF0000
            }
        }}
		
        local one, two = PostWebhook(ToSend, LoggerLink)
        --print(one)
        --print(two)

    end)

end