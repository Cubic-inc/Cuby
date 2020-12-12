return function(Data)
    local Json = require("json")
    Client = Data.Client
    local Guild = Client:getGuild("657227821047087105")

    local SOWMessage = Client:getChannel("786944817984700416"):getMessage("786945231487500308")

    local Emojis = {
        "1️⃣",
        "2️⃣",
        "3️⃣",
        "4️⃣",
        "5️⃣",
        "6️⃣",
        "7️⃣",
        "8️⃣",
        "9️⃣",
        "🔟"
    }

    Client:on("reactionAdd", function(Reaction, User)
        User = Client:getUser(User)
        if User.bot then return end
        if Reaction.message == SOWMessage then
            for i, v in pairs(Emojis) do
                if v ~= Reaction.emojiName then
                    SOWMessage:removeReaction(v, User.id)
                end
            end
        end

    end)

    Client:on("reactionRemove", function(Reaction, User)
        User = Client:getUser(User)
        --if not User.bot then return end
        if Reaction.message == SOWMessage and not Reaction.me then
            for i, v in pairs(Emojis) do
                if v ~= Reaction.emojiName then
                    SOWMessage:addReaction(v)
                end
            end
        end

    end)

    local Message = Client:getChannel("685066367526895658"):getMessage("786914820003856424")

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
                
                local Base = require("Code/Save"):GetDatabase("money")

                local CurrentM = Base:GetAsync(UserId) or 0
                local NewM = CurrentM + 100

                Base:PostAsync(UserId, NewM)

                Message:reply("Thanks for the BUMP <@" .. UserId .. ">! +100$")
            end

        end
    
    end)

    coroutine.wrap(function()
        while true do 
            Client:getGuild("657227821047087105"):getChannel("787278522787037205"):setName("Member count: " .. tostring(Client:getGuild("657227821047087105").totalMemberCount))
            require("timer").sleep(5*60*1000)
        end

    end)()

    

end