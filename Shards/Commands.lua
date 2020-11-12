return function(Data)

    local Handler = Data.CommandHandler

    local SayAsCommand = Handler.New()
    SayAsCommand:SetName("say")
    SayAsCommand:SetMinPerm("Owner")
    SayAsCommand:SetFunction(function(MSG, Args, Raw)
        MSG:reply("" .. table.concat(Raw, " "))
        MSG:delete()
	end)

	local MisfortuneCommand = Handler.New()
    MisfortuneCommand:SetName("Misfortune")
	MisfortuneCommand:SetMinPerm("Owner")

	local MisMemberArg = MisfortuneCommand:NewArg()
	MisMemberArg:SetName("Member mension")
	MisMemberArg:SetType("Member")
	MisMemberArg:SetReq(true)

    MisfortuneCommand:SetFunction(function(MSG, Args, Raw)
		
		local BaseLink = "https://sparkcommunity.eu/media/misfortune/"

		local What = math.random(0, 8)
		local Time = math.random(5, 15)

		local WhatMeanings = {

			[0] = "Trusted",
			[1] = "Nothing",
			[2] = "Misfortune",
			[3] = "Nothing",
			[4] = "Misfortune",
			[5] = "Nothing",
			[6] = "Misfortune",
			[7] = "Nothing",
			[8] = "Misfortune",

		}

		--775668328035254282

		local PngLink = BaseLink .. What .. ".png"
		local GifLink = BaseLink .. What .. ".gif"

		local Embed = {

			title = "The big wheel of misfortune",
			description = "Spinning for: " .. Args[1].user.tag,
			image = {url = GifLink},
			thumbnail = {url = Args[1].user.avatarURL},

		}

		local Reply = MSG:reply({embed = Embed})

		require("Timer").sleep(11000)

		Embed.image.url = PngLink
		Embed.description = Args[1].user.tag .. " has won " .. WhatMeanings[What] .. "!"

		Reply:update({embed = Embed})

		require("Timer").sleep(3000)

		if WhatMeanings[What] == "Nothing" then
			MSG:reply("<a:misfortune:775672372653064204> Congrats " .. Args[1].user.mentionString .. " You have won nothing!")
		elseif WhatMeanings[What] == "Misfortune" then
			MSG:reply("<a:misfortune:775672372653064204> Congrats " .. Args[1].user.mentionString .. " you have won" .. Time .. " Minutes of Misfortune !")
		elseif WhatMeanings[What] == "Trusted" then
			MSG:reply("<a:misfortune:775672372653064204> Congrats " .. Args[1].user.mentionString .. " you are now trusted for " .. Time .. " Minutes!")
		end
		if WhatMeanings[What] == "Ongeluk" then
			Args[1]:addRole("765149108985266217")
			require("Timer").sleep(Time * 60 * 1000)
			Args[1]:removeRole("765149108985266217")
		elseif WhatMeanings[What] == "Vertrouwd" then
			Args[1]:addRole("775668328035254282")
			require("Timer").sleep(Time * 60 * 1000)
			Args[1]:removeRole("775668328035254282")
		end

	end)
	
	local SetStatus = Handler.New()
    SetStatus:SetName("setstatus")
    SetStatus:SetMinPerm("Owner")
	SetStatus:SetFunction(function(MSG, Args, Raw)
		
		_G.Client:setGame({name = "" .. table.concat(Raw, " "), type = 0})

		local Base = require("Code/Save"):GetDatabase("botinfo")
		Base:PostAsync("Status", "" .. table.concat(Raw, " "))
		
        MSG:delete()
    end)

    local PingCommand = Handler.New()
	PingCommand:SetName("ping")
	PingCommand:SetFunction(function(MSG) MSG:reply("Pong! <:hotcomputer:685867382073196712>") end)
	
	
    local SteelNoodleCommand = Handler.New()
	SteelNoodleCommand:SetName("steel-noodle")
	SteelNoodleCommand:SetFunction(function(MSG) MSG:reply("Noedel gestolen! Stik in huigen Tije") end)
	

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
		MSG:reply("You are " .. math.random(0, 100) .. "% Cool :ice_cube: " .. MSG.author.mentionString)
    end) 
    
	--require("Code/StickyCommands")(Data)

end
