local Timer = require("timer")

return function(a) 
    local sec = tonumber(os.clock() + a); 
    while (os.clock() < sec) do 
    end
end

