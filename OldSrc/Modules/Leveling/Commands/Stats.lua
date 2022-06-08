return function(Params)

    local SlashClient = Params.SlashClient

    local Command = {
        name = "stats",
		description = "Get your stats",
		options = {},
		callback = function(Interaction, Parameters, Command)
            Interaction:reply("Test", false)
		end
    }

    Params.PublishCommand(Params.Client, Command)
end