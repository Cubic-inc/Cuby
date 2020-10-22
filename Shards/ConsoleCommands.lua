return function(Data)
    coroutine.wrap(function()

        Data.Libs.Code.Wait(1000)

        local Commands = {
            exit = function()
                Data.Client:setStatus("invisible")
                Data.MilkClient:setStatus("invisible")

                os.exit()
            end,

            cubyoffline = function()
                Data.Client:setStatus("invisible")
            end,

            cubyonline = function()
                Data.Client:setStatus("online")
            end,

            milkoffline = function()
                Data.MilkClient:setStatus("invisible")
            end,

            milkonline = function()
                Data.MilkClient:setStatus("online")
            end,

            alloffline = function()
                Data.MilkClient:setStatus("invisible")
                Data.Client:setStatus("invisible")
            end,

            allonline = function()
                Data.MilkClient:setStatus("online")
                Data.Client:setStatus("online")
            end,
        }

        local LastRoundCommand = true
        
        while true do
            
            if LastRoundCommand then
                LastRoundCommand = true
            print()
            print("insert next command: ")
            local Command = io.read()
            end

            if Command then
                Command = string.lower(Command)

                if Commands[Command] then
                    Commands[Command]()
                else
                    print("Command not found")
                end
            else
                LastRoundCommand = false
            end 

        end

    end)()

end