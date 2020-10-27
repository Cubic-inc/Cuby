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

        if MentionedArray[1].id == Data.Author.id then
            Data.PreMSG:setContent("Je kan jezelf niet warnen!")
            return
        end


        if MentionedArray[1].id == "533536581055938580" then
            --print("no u")
            --Data.Channel:send("No u\nhttps://tenor.com/view/reverse-card-uno-uno-cards-gif-13032597")
            --print(1)
            Data.ShardData.Libs.Code.Warn(Data.PreMSG, nil, Data.Author, Data.Author, "No u", Data)
            --print(2)
        else   
            Data.ShardData.Libs.Code.Warn(Data.PreMSG, nil, MentionedArray[1], Data.Author, Reason, Data)
        end
    elseif SubCommand == "list" then

        

        local WarnData = Base:GetAsync(MentionedArray[1].id) or {}

        local Embed = {
            title = MentionedArray[1].name .. "'s Warnings",

            --description = "",

            fields = {



            }

        }

        local Query = require("querystring")
        

        for i, v in pairs(WarnData) do

            --Embed.description = Embed.description .. "**Warning id: " .. v.Id .. "**" .. "\nModerator: `" ..Data.ShardData.Client:getUser(v.Moderator).tag .. "`\nRede: `" .. v.Rede .. "`\nTijd: `" .. v.Tijd .. "`\nLink: [Message](" .. Query.urldecode(v.Link) .. ")"

            local Field = {name = "**Warning id: " .. v.Id .. "**", value = "Moderator: `" ..Data.ShardData.Client:getUser(v.Moderator).tag .. "`\nRede: `" .. v.Rede .. "`\nTijd: `" .. v.Tijd .. "`\nLink: [Message](" .. Query.urldecode(v.Link) .. ")", inline = true}
            table.insert(Embed.fields, Field)
        end
        

        Data.PreMSG:update({content = "", embed = Embed})

    elseif SubCommand == "amount" then

        --print(1)

        local WarnData = Base:GetAsync(MentionedArray[1].id) or {}

        --print(2)
        local Embed = {
            title = MentionedArray[1].name .. " Heeft:",

            description = tostring(#WarnData) .. " Warnigns",

        }
        --print(2)

        --local Query = require("querystring")
        

        --print(3)

        Data.PreMSG:update({content = "", embed = Embed})

    elseif SubCommand == "clear" then

        --[[if MentionedArray[1].id == Data.Author.id then
            Data.PreMSG:setContent("Je kan je eigen warnings niet weghalen!")
            return
        end]]

        local Embed = {
            description = "**" .. Member.tag .. "** zijn warns zijn weg gehaald",
        }

        print("clear")
        
        Data.PreMSG:update({content = "", embed = Embed})
        print(Base:PostAsync(MentionedArray[1].id, nil))

        print("tstets")
        print("done")
    else
        Data.PreMSG:setContent("Je moet een sub commando geven!")
    end

   
end