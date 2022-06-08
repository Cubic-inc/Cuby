local Module = {}

local MoneyBase = require("Save"):GetDatabase("money")
local LevelBase = require("Save"):GetDatabase("levels")

function Module.AddXp(User, Amount)
    local CurrentM = LevelBase:GetAsync(User.id) or 0
    local NewM = CurrentM + Amount

    LevelBase:PostAsync(User.id, NewM)
end

function Module.RemoveXp(User, Amount)
    local CurrentM = LevelBase:GetAsync(User.id) or 0
    local NewM = CurrentM - Amount

    LevelBase:PostAsync(User.id, NewM)
end

function Module.GetXp(User)
    local CurrentM = LevelBase:GetAsync(User.id) or 0
    return CurrentM
end

function Module.GetLevel(User)
    local Xp = require("Level").GetXp(User)

    return _G.CalcLevel(Xp)
end





function Module.AddMoney(User, Amount)
    local CurrentM = MoneyBase:GetAsync(User.id) or 0
    local NewM = CurrentM + Amount

    MoneyBase:PostAsync(User.id, NewM)
end

function Module.RemoveMoney(User, Amount)
    local CurrentM = MoneyBase:GetAsync(User.id) or 0
    local NewM = CurrentM - Amount

    MoneyBase:PostAsync(User.id, NewM)
end

function Module.GetMoney(User)
    local CurrentM = MoneyBase:GetAsync(User.id) or 0
    return CurrentM
end

return Module