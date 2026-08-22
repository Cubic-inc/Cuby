return function ()
    
    local Log = require("Log")

    Client:on("voiceChannelJoin", function(Member, Channel)
        
        if Member.user.bot == true then return end
        if not Channel then return end
		
        local LogTitle = "Channel Join"

        local LogFields = {
            {name = "**Channel**", value = "`" .. Channel.name .. "`", inline = true},
            {name = "**Member**", value = "`" .. Member.tag .. "`", inline = true}
        }
                
        local LogColor = 0x00FF00
		
        Log(LogTitle, LogFields, LogColor)

    end)

    Client:on("voiceChannelLeave", function(Member, Channel)


        if Member.user.bot == true then return end
        if not Channel then return end
		
        local LogTitle = "Channel Leave"

        local LogFields = {
                    {name = "**Channel**", value = "`" .. Channel.name .. "`", inline = true},
                    {name = "**Member**", value = "`" .. Member.tag .. "`", inline = true},
        }

        local LogColor = 0xFF0000

		
        Log(LogTitle, LogFields, LogColor)

    end)

    Client:on("messageDelete", function(Message)

        if not Message then return end
        if Message.author.bot == true then return end
	if not Message.guild then return end
        

        local LogTitle = "Message Delete"
        local LogFields = {
            {name = "**Content**", value = "`" .. Message.cleanContent .. "`", inline = true},
            {name = "**Member**", value = "`" .. Message.author.tag .. "`", inline = true},
	    {name = "**Channel**", value = "`" .. Message.channel.name .. "`", inline = true}
        }
                
        local LogColor = 0xFF0000
    
		
        Log(LogTitle, LogFields, LogColor)

    end)

end
