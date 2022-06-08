return function(Data)
    if not Data.Args[1] then Data.PreMSG:setContent(Data.Author.mentionString .. " Please add a String!") return end

    local Emojify = require("./Emojifyer.lua")
    local String, Error = Emojify(table.concat(Data.Args, " "))
        

    if Error[1] then
        Data.PreMSG:setContent(Data.Author.mentionString .. " I think this is your string: " .. String .. "\n uum, there was an error. The following symbols did not get transferd: " .. table.concat(Error, ", "))
    else
        Data.PreMSG:setContent(Data.Author.mentionString .. " I think this is your string: " .. String)
    end
end