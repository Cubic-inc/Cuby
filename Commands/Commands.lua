
return function ()
    local Slash = _G.Slash
    local SaveCommand = _G.SaveCommand

    local PingCommand = Slash.new("ping", "Pong! | Access for everyone")
    PingCommand:callback(function (Inter, Params, Cmd)
        Inter:reply("Pong, Cuby operational.")
    end)

    SaveCommand(PingCommand)

    local CoolCommand = Slash.new("cool", "Get your cool % | Access for everyone!")
	CoolCommand:callback(function(Inter, Params, Cmd)
		Inter:reply("You are " .. math.random(0, 100) .. "% Cool :ice_cube: " .. Inter.member.user.mentionString)
    end) 

    SaveCommand(CoolCommand)

    local InfoCommand = Slash.new("info", "Get info | Access for everyone!")
	InfoCommand:callback(function(Inter, Params, Cmd)

		local TimeTable = _G.Watch:getTime()
		local TimeString = TimeTable:toString()

		Inter:reply(
            {
                embeds = {
                    {
                        title = "Bot info",
                        author = {name = _G.Client.user.tag, icon_url = _G.Client.user.avatarURL},
                        fields = {
                            {name = "Version", value = require("../package.lua").version, inline = true},
                            {name = "Uptime", value = TimeString, inline = true},
                            {name = "Creator", value = "<@533536581055938580>", inline = true},
			            }
                    }
                }
            }, true, false)
    end)
    
    SaveCommand(InfoCommand)
end