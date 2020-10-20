return function(Xp)
    local Count = 100
    return math.max(math.floor(math.log(Xp/Count) / math.log(2.1) + 2), 1) - 1
end