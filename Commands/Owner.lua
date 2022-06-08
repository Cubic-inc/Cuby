return function ()

    local Client = _G.Client
    local Slash = _G.Slash
    local SaveCommand = _G.SaveCommand
    local Format = _G.Format
    local OptionType = Slash.enums.optionType
    local SendHook = require("SendHook")
    local MuteModule = require("Mute")


    local SudoCommand = Slash.new("sudo", "sudo a user | Owner only!")
    SudoCommand:option("user", "User to sudo.", OptionType.user, true)
    SudoCommand:option("string", "string to send", OptionType.string, true)

	SudoCommand:callback(function(Inter, Params, Cmd)
		
		if not UserIs(Inter, "Owner") then
			return
		end

        Inter:ack(true)

        local SudoData = {
            content = Params.string,
            username = Params.user.name,
            avatar_url = Params.user.user.avatarURL
        }

        SendHook(Inter.channel, SudoData)
    end)
    
    SaveCommand(SudoCommand)

    local MisfortuneCommand = Slash.new("misfortune", "Give someone misfortune >:) | Head Admin only!")

    MisfortuneCommand:option("user", "User to give misfortune LOL", OptionType.user, true)

	MisfortuneCommand:callback(function(Inter, Params, Cmd)
		
		if not UserIs(Inter, "HeadAdmin") then
			return
		end
		
        local BaseLink = "https://sparkcommunity.eu/media/misfortune/"
        local ToFortune = Params.user

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
			description = "Spinning for: " .. ToFortune.user.tag,
			image = {url = GifLink},
			thumbnail = {url = ToFortune.user.avatarURL},

		}

		Inter:reply({embeds = {Embed}})

		require("Timer").sleep(11000)

		Embed.image.url = PngLink
		Embed.description = ToFortune.user.tag .. " has won " .. WhatMeanings[What] .. "!"

		Inter:update({embeds = {Embed}})

		require("Timer").sleep(3000)

		if WhatMeanings[What] == "Nothing" then
			Inter:followUp("<a:misfortune:775672372653064204> Congrats " .. ToFortune.user.mentionString .. " You have won nothing!")
		elseif WhatMeanings[What] == "Misfortune" then
			Inter:followUp("<a:misfortune:775672372653064204> Congrats " .. ToFortune.user.mentionString .. " you have won " .. Time .. " Minutes of Misfortune !")
		elseif WhatMeanings[What] == "Trusted" then
			Inter:followUp("<a:misfortune:775672372653064204> Congrats " .. ToFortune.user.mentionString .. " you are now trusted for " .. Time .. " Minutes!")
		end
        if WhatMeanings[What] == "Misfortune" then
            MuteModule.Mute(ToFortune, "Misfortuned and got bonked!", Inter.channel, Time)
		elseif WhatMeanings[What] == "Trusted" then
			ToFortune:addRole("775668328035254282")
			require("Timer").sleep(Time * 60 * 1000)
			ToFortune:removeRole("775668328035254282")
		end

    end)
    
	SaveCommand(MisfortuneCommand)
	
	local SayCommand = Slash.new("say", "Say as the bot | Head Admin only!")
	SayCommand:option("string", "String to send", OptionType.string, true)
	SayCommand:callback(function (Inter, Params, Cmd)
		if not UserIs(Inter, "HeadAdmin") then
			return
		end

		Inter:reply(Params.string, true)
	end)

	SaveCommand(SayCommand)
end