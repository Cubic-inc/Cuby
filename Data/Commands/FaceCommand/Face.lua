

return function(Data)
    local Faces = require("./Faces.lua")
    local Face = Faces[math.random(1, #Faces)]
    Data.PreMSG:setContent(Face.Name .. "\n" .. Face.ImageURL)
end