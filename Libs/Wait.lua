return function(Time)
    local clock = os.clock
    local t0 = clock()
    while clock() - t0 <= Time do end

end