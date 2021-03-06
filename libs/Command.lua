local Commands = {}

local Module = {Commands = {}}

function GetUserByPing(Text, Client)

    local Id = string.sub(Text, 4, 21)
    if not Id then return end
    if not tonumber(Id) then return end

    local ToReturn = Client:getUser(Id)

    return ToReturn
end

function New(Client)

    

    local Guilds = {
        Cubic = Client:getGuild("657227821047087105"),
        Coen = Client:getGuild("762697110214017045"),
        Tije = Client:getGuild("761853654428024852"),
        Martje = Client:getGuild("766576140156272661"),

    }

    local CoreByteID = Client.owner.id

    local GuildRoles = {

        [657227821047087105] = { -- main guild
            Admin = "760223306417700875",
            Moderator = "760223388185788429"
        },
        [762697110214017045] = { -- coen
            Admin = "762697110214017048",
            Moderator = "772117895667777549"
        },
        [761853654428024852] = { -- tije
            Admin = "761853989569691658",
            Moderator = "772117810369003574"
        },
        [766576140156272661] = { -- martje
            Admin = "766576140156272664",
            Moderator = "766576140348424236"
        }



    }

    local Info = {Prefix = "!", Args = {}, Perm = "User", Desc = "No description", Group = "Other"}
    local NewCommand = {Info}
    
    table.insert(Module.Commands, Info)

    Client:on("messageCreate", function(MSG)  

        local Text = MSG.content

        if string.sub(Text, 1, 1) ~= Info.Prefix then --[[print("Prefix not found")]] return end

        local ToParse = string.sub(Text, #Info.Prefix+1)
        local Args = {}
        for C in ToParse:gmatch("%S+") do
            table.insert(Args, tostring(C))
            --print(C)
        end

        if string.lower(Args[1] or "") ~= Info.Name then --[[print("Command not found")]] return end
        table.remove(Args, 1)

        if not MSG.guild then
            MSG:reply("Only use this command in servers!")
            return
        end

        if Info.Perm == "Mod" then
            if MSG.member:hasRole(GuildRoles[tonumber(MSG.guild.id)].Moderator) then

            else
                MSG:reply("<:__:667069785913163786> Only **__MODERATORS__** can use this command!")
                return
            end
        end

        if Info.Perm == "Admin" then
            if MSG.member:hasRole(GuildRoles[tonumber(MSG.guild.id)].Admin) then

            else
                MSG:reply("<:__:667069785913163786> Only **__ADMINS__** can use this command!")
                return
            end
        end

        if Info.Perm == "Owner" then
            if MSG.author.id == CoreByteID then

            else
                MSG:reply("<:__:667069785913163786> Only **__COREBYTE#1161__** can use this command!")
                return
            end
        end

        local NewArgs = {}
        for i, v in pairs(Info.Args) do
            if Args[i] then

                if v.Type == "Member" then
                    
                    local FoundUser = GetUserByPing(Args[i], Client)

                    local Found

                    if FoundUser then
                        Found = MSG.guild:getMember(FoundUser.id)
                    else
                        Found = nil
                    end
                    

                    if Found == nil then
                        MSG:reply("An error occured while parsing argument **`" .. v.Name .. "`**")
                        return
                    else
                        table.insert(NewArgs, i, Found)
                    end

                elseif v.Type == "User" then

                    local Found = GetUserByPing(Args[i], Client)

                    if Found == nil then
                        MSG:reply("An error occured while parsing argument **`" .. v.Name .. "`**")
                        return
                    else
                        table.insert(NewArgs, i, Found.user)
                    end
                else
                    table.insert(NewArgs, i, Args[i])
                end

            elseif v.Type == "Number" then

                local Found = nil

                Found = tonumber(Args[i])

                if Found == nil then
                    MSG:reply("Argument **`" .. v.Name .. "`** must be a number")
                    return
                else
                    table.insert(NewArgs, i, Found.user)
                end

            else
                if v.Req == true then
                    MSG:reply("Argument **`" .. v.Name .. "`** Is required!")
                    return
                else
                    --print(v.Req)
                    break
                end
            end

            --print("arg", Args[i])
        end

        if Info.Function then
            Info.Function(MSG, NewArgs, Args)
        else
            MSG:reply("An internal command error occured: `Command function not found`")
        end

    end)

    

    function NewCommand:SetPrefix(Prefix)
        Info.Prefix = Prefix
    end

    function NewCommand:SetName(Name)
        Info.Name = string.lower(Name)
        --print("Name set: " .. Name)
    end

    function NewCommand:SetFunction(Function)
        Info.Function = Function
        --print("Function set: " .. tostring(Function))
    end

    function NewCommand:SetAliases(TableAliases)
        Info.Aliases = TableAliases
    end

    function NewCommand:SetGroup(Group)
        Info.Group = Group
    end

    function NewCommand:SetMinPerm(Perm)
        if Perm == "Owner" or Perm == "Admin" or Perm == "Mod" or Perm == "Vip" or Perm == "User" then
            Info.Perm = Perm
            --print("Set perm: " .. Perm)
        else
            print("Incorrect Perms")
            return
        end
    end

    function NewCommand:SetDesc(Desc)
        Info.Desc = Desc
        --print("Desk set: " .. Desk)
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

        function Arg:SetLower(Bool)
            Argument.Lower = Bool
        end

        table.insert(Info.Args, #Info.Args + 1, Argument)

        --print("New Arg made")

        return Arg
    end

    table.insert(Commands, #Commands + 1, Info)

    return NewCommand
end



function Module:Init(Client)
    return {Commands = Module.Commands, New = function() return New(Client) end, }
end



return Module