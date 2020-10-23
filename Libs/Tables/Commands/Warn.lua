return function(Data)
    local MentionedArray = Data.OrgMSG.mentionedUsers:toArray()

    if not MentionedArray[1] then
        Data.PreMSG:setContent("Je moet iemand pingen!")
        return 
    end

    local Base = Data.ShardData.Libs.Code.Save:GetDatabase("warnings")
    

    local SubCommand = Data.Args[1]
    table.remove(Data.Args, 1)

    print(SubCommand)

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

        

        local WarnData = Base:GetAsync(MentionedArray[1].id) or {}

        local Embed = {
            title = MentionedArray[1].name .. "'s Warnings",

            fields = {



            }

        }

        local Query = require("querystring")
        

        for i, v in pairs(WarnData) do

            local Field = {name = "Warning id: " .. v.Id, value = "Moderator: `" ..Data.ShardData.Client:getUser(v.Moderator).tag .. "`\nRede: `" .. v.Rede .. "`\nTijd: `" .. v.Tijd .. "`\nLink: [Message](" .. Query.urldecode(v.Link) .. ")", inline = true}
            table.insert(Embed.fields, Field)
        end
        

        Data.PreMSG:update({content = "", embed = Embed})

    elseif SubCommand == "clear" then
        print("clear")
        print(Base:PostAsync(MentionedArray[1].id, nil))
        print("tstets")
        Data.PreMSG:update({content = "", embed = {description = "**" .. Member.tag .. "** zijn warns zijn weg gehaald"}})

        print("done")
    else
        Data.PreMSG:setContent("Je moet een sub commando geven!")
    end

   
end