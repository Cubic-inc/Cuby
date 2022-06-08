return function ()
    
    local Levels = require("Level")

    Client:on("messageCreate", function(Message)
        local Channel = Message.channel
        local User = Message.author

        if User.id == "302050872383242240" then

            if not Message.embed then return end
            if not Message.embed.image then return end

            if Message.embed.image.url == "https://disboard.org/images/bot-command-image-bump.png" then 
                --print("yes")
                --print(Message.embed.description)
                local UserId = string.sub(Message.embed.description, 3, 20)
                
                local UserTo = Client:getUser(UserId)

                Levels.AddMoney(UserTo, 100)

                Message:reply("Thanks for the BUMP <@" .. UserId .. ">! +100$")
            end

        end
    
    end)

end