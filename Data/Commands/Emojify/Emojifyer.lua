List = require("./List.lua")

return function(String)
    local Sub = string.sub

    local Out = ""
    local NotFound = {}

    String = tostring(String)
    String = String:lower()

    for i = 1, #String do
        if List[Sub(String, i, i)] then
            Out = Out .. List[Sub(String, i, i)]
        else
            table.insert(NotFound, tostring(Sub(String, i, i)))
        end

        
    end
    --print(#NotFound)
    return Out, NotFound

end