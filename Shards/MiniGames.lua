return function(Data)

    local Json = require("json")
    local PP = require('pretty-print')

    Client = Data.Client

    local Channel = Client:getChannel("769510813588914186")
    local Guild = Client:getGuild("657227821047087105")

    local Messages = {
        Amongo = Channel:getMessage("770300036508418098"),
    }

    local Roles = {
        Amongo = Guild:getRole("769574625553678366")
    }

    local BeginAmounts = {
        Amongo = #Messages.Amongo.reactions:toArray()

    }

    --print(Data.Libs.Code.TableToString(Messages.Amongo.reactions:toArray()))

    Client:on("reactionAdd", function(Reaction, UserId)
    
        local User = Client:getUser(UserId)
        local Member = Guild:getMember(UserId)

        
        
        
    end)


end