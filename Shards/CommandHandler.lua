return function(Data)
    local Client = Data.Client
    local Prefix = Data.Prefix
    local Wait = Data.Libs.Code.Wait
    local Commands = Data.Libs.Tables.Commands
    local WebHooks = Data.Libs.Tables.WebHooks

    Client:on('messageCreate', function(Message)
        local Data = {}
        
        if string.sub(Message.content, 1, 1) == Prefix then
    
            local Args = {}
    
            
    
        end
    end)
end