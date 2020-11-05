return function(Data)

    local Handler = Data.CommandHandler

    local SayAsCommand = Handler.New()
    SayAsCommand:SetName("say")
    SayAsCommand:SetMinPerm("Owner")
    SayAsCommand:SetFunction(function(MSG, Args, Raw)
        MSG:reply("" .. table.concat(Raw, " "))
        MSG:delete()
    end)

    local PingCommand = Handler.New()
	PingCommand:SetName("ping")
	PingCommand:SetFunction(function(MSG) MSG:reply("Pong! <:hotcomputer:685867382073196712>") end)

	local InfoCommand = Handler.New()
	InfoCommand:SetName("info")
	InfoCommand:SetFunction(function(MSG)
		MSG:reply({content = "⠀", embed = {
			title = "Bot info",
			author = {name = "Cuby", icon_url = Client.user.avatarURL},
			fields = {
				{name = "Version", value = "Unknown!", inline = true},
				{name = "Uptime", value = "N/A", inline = true},
				{name = "Creator", value = "<@533536581055938580>", inline = true},
	
			}
		}})
	end)

	local CoolCommand = Handler.New()
	CoolCommand:SetName("cool")
	CoolCommand:SetFunction(function(MSG)
		MSG:reply("Jij bent " .. math.random(0, 100) .. "% Cool :ice_cube: " .. MSG.author.mentionString)
    end) 
    


end