return function(Data)
    local MentionedArray = Data.OrgMSG.mentionedUsers:toArray()

    if Data.Args[1] then
        Reason = table.concat(Data.Args, " ")
    else
        Reason = nil
    end

    Data.ShardData.Libs.Code.Warn(Data.PreMSG, nil, MentionedArray[1], Data.Author, Reason, Data)
end