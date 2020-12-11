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

    

end