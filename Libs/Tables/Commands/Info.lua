return function(Data)

    Data.PreMSG:update({content = "⠀", embed = {

        title = "Bot info",

        author = {name = "Cuby", icon_url = Data.ShardData.Client.user.avatarURL},

        fields = {
            {name = "Version", value = "Unknown!", inline = true},
            {name = "Uptime", value = "N/A", inline = true},
            {name = "Creator", value = "<@533536581055938580>", inline = true},

        }

    }})

end