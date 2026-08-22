local Json = require("json")
local Coro = require("coro-http")
local Wait = require("../../../Libs/Wait.lua")
local TableToString = require("../../../Libs/TableToString.lua")
local Table = table 
local String = string


return function(Data)
    Data.PreMSG:setContent(Data.Author.mentionString .. " You are " .. math.random(0, 100) .. "% cool!")
    Wait(50)
    Data.PreMSG:delete()
end