return function(Data)

    local MentionedArray = Data.OrgMSG.mentionedUsers:toArray()
    if MentionedArray[1] then
        local Member = Data.Guild:getMember(MentionedArray[1].id)
        if Member then
            
            --Data.PreMSG:setContent("")

            if Data.Args[1] then
                local Rede = table.concat(Data.Args[1], " ")
            else
                local Rede = "Geen Rede Gegeven"
            end

            if Member:hasRole("765149108985266217") then
                Member:removeRole("765149108985266217")
                Data.PreMSG:setEmbed({description = ":white_check_mark: **" .. Member.tag .. "** Is Geunmute"})
            else
                Member:addRole("765149108985266217")
                Data.PreMSG:setEmbed({description = ":white_check_mark: **" .. Member.tag .. "** Is Gemute | " .. Rede})
            end

            Data.PreMSG:setContent("Klaar!")
        end
    else
        Data.PreMSG:setContent("Je moet iemand pingen!")
    end
end