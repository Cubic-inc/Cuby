return function(Params)

    local SlashClient = Params.SlashClient

    local Command = {
        name = "cool",
		description = "Check how cool you are 😎.",
		options = {},
		callback = function(Interaction, Parameters, Command)
            Interaction:reply("You are " .. math.random(0, 100) .. "% cool 😎!")
		end
    }

    Params.PublishCommand(Params.Client, Command)
end