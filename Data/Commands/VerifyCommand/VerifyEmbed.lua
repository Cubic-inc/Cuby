local Json = require("json")

local Table = {

   title = "Please verify your account!",
   description = "please follow these steps:",

   fields = {
       {name = "- :one: : ", value = "- Verify your **ROBLOX ACCOUNT** : https://verify.eryn.io/"},
       {name = "- :two: : ", value = "- Join the **CUBIC INC ROBLOX GROUP**"},
       {name = "- :three: : ", value = "- Accept the **SERVER RULES**"},
       {name = "- :four: : ", value = "- Accept the **DISCORD TOS** : https://discordapp.com/guidelines"},
       {name = "- :five: : ", value = "- Accept the **ROBLOX TOS** : https://www.roblox.com/info/terms"},
   },

   footer = {
       icon_url = "http://icons.iconarchive.com/icons/gakuseisean/ivista-2/128/Alarm-Warning-icon.png",
       text = "you already have access to the server but will be removed in 15 minutes if you don't complete the tasks",
   },

   color = require("discordia").Color.fromRGB(126, 211, 33).value,


}

local StringTable = Json.encode(Table)
local CloneTable = Json.decode(StringTable)

return CloneTable