return function(Params)

    local SlashClient = Params.SlashClient

    local Command = {
        name = "pong",
		description = "Pong!",
		options = {},
		callback = function(Interaction, Parameters, Command)
            Interaction:reply("Pong!")
		end
    }

    Params.PublishCommand(Params.Client, Command)
end