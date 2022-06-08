return function (Title, Fields, Color)
    local Data = {
        embeds = {{
            title = Title,
            fields = Fields,
            color = Color,

            footer = {text = "At"},
            timestamp = _G.GetTimeStamp()
        }},

        username = "Cuby Logger",
        avatar_url = "https://cdn.discordapp.com/attachments/762660805534679050/762661612372099072/Logo_Smaller_can.png",

    }

    local SendHook = require("SendHook")
    local LogChannel = _G.LogChannel

    SendHook(LogChannel, Data)

end