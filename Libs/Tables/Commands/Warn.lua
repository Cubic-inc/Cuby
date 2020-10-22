return function(Data)
    local MentionedArray = Data.OrgMSG.mentionedUsers:toArray()

    if not MentionedArray[1] then
        Data.PreMSG:setContent("Je moet iemand pingen!")
        return 
    end

    local Base = Data.ShardData.Libs.Code.Save:GetDatabase("warnings")


    local SubCommand = Data.Args[1]
    table.remove(Data.Args, 1)

    if SubCommand == "add" then
        if Data.Args[1] then
            Reason = table.concat(Data.Args, " ")
        else
            Reason = nil
        end

        --[[if MentionedArray[1].id == Data.Author.id then
            Data.PreMSG:setContent("Je kan jezelf niet warnen!")
            return
        end]]

        Data.ShardData.Libs.Code.Warn(Data.PreMSG, nil, MentionedArray[1], Data.Author, Reason, Data)
    elseif SubCommand == "get" then
        local All = Base:GetStoreAsync()

        local WarnData = Base:GetAsync(MentionedArray[1].id)

        local Embed = {
            title = MentionedArray[1].name .. "'s Warnings",

            fields = {



            }

        }

        local Query = require("querystring")

        for i, v in pairs(WarnData) do
            local Field = {name = "Warning id: " .. v.Id, value = "Moderator: `" .. Data.ShardData.Client:getUser(v.Moderator).tag .. "`\nRede: `" .. v.Rede .. "`\nTijd: `" .. v.Tijd .. "`\nLink: [Message](" .. Query.urldecode(v.Link) .. ")"}
            table.insert(Embed.fields, Field)
        end


        Data.PreMSG:update({content = "", embed = Embed})


    else
        Data.PreMSG:setContent("Je moet een sub commando geven!")
    end

   
end