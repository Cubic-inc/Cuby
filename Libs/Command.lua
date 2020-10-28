function New(Client)

    Client:on("messageCreate", function()
        
        

    end)

    local Info = {}
    local NewCommand = {Info}

    function NewCommand:SetPrefix(Prefix)
        Info.Prefix = Prefix
    end

    function NewCommand:SetName(Name)
        Info.Name = Name
    end

    function NewCommand:SetFunction(Function)
        Info.Function = Function
    end

    function NewCommand:SetAliases(TableAliases)
        Info.Aliases = TableAliases
    end

    function NewCommand:SetMinPerm(Perm)
        if Perm == "Owner" or Perm == "Admin" or Perm == "Mod" or Perm == "Vip" or Perm == "User" then
            Info.Perm = Perm
        else
            print("Incorrect Perms")
            return
        end
    end

    function NewCommand:SetDesk(Desk)
        Info.Desk = Desk
    end

    function NewCommand:SetClient(NumberClient)
        Info.Client = NumberClient
    end

    return NewCommand
end

function Init(Client)
    return {Commands = {}, New = function() return New(Client) end, }
end


return Init