return function(Data)

    local MentionedArray = Data.OrgMSG.mentionedUsers:toArray()
    if MentionedArray[1] then
        local Member = Data.Guild:getMember(MentionedArray[1].id)
        if Member then
            
            Data.PreMSG:setContent("")

            local Rede = table.concat(Data.Args[1], " ") or "Geen Rede Gegeven"

            if Member:hasRole("765149108985266217") then
                Member:removeRole("765149108985266217")
                Data.PreMSG:update({content = nil, embed = {description = ":white_check_mark: **" .. Member.tag .. "** Is Geunmute"}})
            else
                Member:addRole("765149108985266217")
                Data.PreMSG:update({content = nil, embed = {description = ":white_check_mark: **" .. Member.tag .. "** Is Gemute | " .. Rede}})
            end
        end
    else
        Data.PreMSG:setContent("Je moet iemand pingen!")
    end
end