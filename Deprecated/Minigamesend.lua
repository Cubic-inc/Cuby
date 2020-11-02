return nil

--[[
	local Channel = Client:getChannel("769510813588914186")

	local MSG = Channel:send({content = "", embed = {
		title = "**Amongo!**",
		description = "Reageer met <:plusbutton:685867382144893013> om mee te doen met amongo"
	}})

	local emoji = Client:getGuild("657227821047087105").emojis:find(function(e) return e.name == 'plusbutton' end)

	MSG:addReaction(emoji)]]