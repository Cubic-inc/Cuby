return function(...)
    local arr = {}
    for i, v in pairs(...) do
        arr[#arr + 1] = v
    end
    return arr
end
  
