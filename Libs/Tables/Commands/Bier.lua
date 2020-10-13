return function(Data)
    local GlobalData = Data.ShardData.GlobalValues

    if not Data.Args[1] then
        Data.PreMSG:setContent("Geen sub commando gegeven")
    elseif string.lower(Data.Args[1]) == "drink" and GlobalData.Milk == true then
        Data.PreMSG:setContent(":beer: Slurp Slurp ")
        GlobalData.Milk = false
    elseif string.lower(Data.Args[1]) == "drink" and GlobalData.Milk == false then
        Data.PreMSG:setContent(":beer: Het Glas is leeg :frowning2: ")
    elseif string.lower(Data.Args[1]) == "fill" and GlobalData.Milk == false then
        Data.PreMSG:setContent(":beer: Klok Klok")
        GlobalData.Milk = true
    elseif string.lower(Data.Args[1]) == "fill" and GlobalData.Milk == true then
        Data.PreMSG:setContent(":beer: Het glas is al vol :frowning2:")
    else
        Data.PreMSG:setContent("Sub command go Brrrrr")
    end

end