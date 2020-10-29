local Commands = {}


function New(Client)

    local Info = {Prefix = "!", Args = {}}
    local NewCommand = {Info}

    Client:on("messageCreate", function(MSG)
        
        local Args = {}

        

        local Text = MSG.cleanContent

        if string.sub(Text, 1, 1) ~= Info.Prefix then --[[print("Prefix not found")]] return end

        for C in string.gmatch(string.sub(Text, #Info.Prefix), "%a+") do
            table.insert(Args, string.lower(tostring(C)))
            print(C)
        end

        print(11)
        print(Args[1])

        

        if Args[1] ~= Info.Name then print("Command not found") return end

        table.remove(Args, 1)

        for i, v in pairs(Info.Args) do
            print(i)
            --print("arg")

            if Args[i] then

                if v.Type == "Member" then
                    local Found = MSG.guild.members:find(function(Member)
                        return Member.name == Args[i]
                    end)

                    if Found == nil then
                        MSG:reply("An error occured while parsing argument **`" .. v.Name .. "`**")
                        return
                    end
                end

            else
                if v.Req == true then
                    MSG:reply("Argument **`" .. v.Name .. "`** Is required!")
                    return
                else
                    print(v.Req)
                end
            end

            print("arg", Args[i])
        end

        if Info.Function then
            Info.Function(MSG, Args)
        else
            MSG:reply("An internal command error occured: `Command function not found`")
        end

    end)

    

    function NewCommand:SetPrefix(Prefix)
        Info.Prefix = Prefix
    end

    function NewCommand:SetName(Name)
        Info.Name = string.lower(Name)
        print("Name set: " .. Name)
    end

    function NewCommand:SetFunction(Function)
        Info.Function = Function
        print("Function set: " .. tostring(Function))
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
        print("Desk set: " .. Desk)
    end

    function NewCommand:NewArg()
        local Argument = {Type = "String", Req = false, Name = "Unknown"}
        local Arg = {}

        function Arg:SetType(StringType)
            Argument.Type = StringType
        end

        function Arg:SetReq(BoolReq)
            Argument.Req = BoolReq
        end

        function Arg:SetName(Name)
            Argument.Name = Name
        end

        table.insert(Info.Args, #Info.Args + 1, Argument)

        print("New Arg made")

        return Arg
    end

    table.insert(Commands, #Commands + 1, Info)

    return NewCommand
end

local Module = {}

function Module:Init(Client)
    return {Commands = {}, New = function() return New(Client) end, }
end



return Module