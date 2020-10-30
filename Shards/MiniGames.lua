return function(Data)

    local Json = require("json")
    --local PP = require('pretty-print')

    Client = Data.Client

    local Channel = Client:getChannel("769510813588914186")
    local Guild = Client:getGuild("657227821047087105")

    local Messages = {
        Amongo = Channel:getMessage("770300036508418098"),
    }

    local Roles = {
        Amongo = Guild:getRole("769574625553678366")
    }

    local Reactions = {
        Amongo = Messages.Amongo.reactions:toArray()[1]
    }

    local BeginAmounts = {
        Amongo = Reactions.Amongo.count
    }

    print(Messages.Amongo.reactions:toArray()[1].count)
    for i, v in pairs(Messages.Amongo.reactions:toArray()) do
        print(v)
    end

    Client:on("reactionAdd", function(Reaction, UserId)
    
        local User = Client:getUser(UserId)
        local Member = Guild:getMember(UserId)

        if BeginAmounts.Amongo ~= Reactions.Amongo.count then
            Member:addRole("769574625553678366")
            BeginAmounts.Amongo = Reactions.Amongo.count 
        end
        
        
    end)

    Client:on("reactionRemove", function(Reaction, UserId)
    
        local User = Client:getUser(UserId)
        local Member = Guild:getMember(UserId)

        if BeginAmounts.Amongo ~= Reactions.Amongo.count then
            Member:removeRole("769574625553678366")
            BeginAmounts.Amongo = Reactions.Amongo.count 
        end
        
        
    end)


end