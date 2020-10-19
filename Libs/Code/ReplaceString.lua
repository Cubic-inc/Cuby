return function(String, Values)

    if not String then return end

    local ReplacedString = String

    for i, v in pairs(Values) do

        ReplacedString = string.gsub(ReplacedString, "{" .. i .. "}", v)



    end

    return ReplacedString

end