local Table = table 
local String = string
local Json = require("json")
local TableToString = require("../../../Libs/TableToString.lua")

--local Wait = require("./Libs/Wait.lua")
local Wait = require("timer").sleep


return function(RunnerData)
    
    RunnerData.Client:on("messageCreate", function(MSG)
        local Text = string.lower(MSG.content)
        local Channel = MSG.channel
        local Author = MSG.author
        
        
        if String.sub(Text, 1, 1) == RunnerData.Prefix then

            local PreMSG = MSG:reply("Working please wait")

            local Args = {}
            local Data = {}
            
            local Commands = require("../../../Commands.lua")
            
            for C in String.gmatch(String.sub(Text, 2), "%a+") do
                Table.insert(Args, tostring(C))
            end
            local Command = Args[1]
            
            Table.remove(Args, 1)
    
            --Creating the data
    
            Data.Args = Args
            Data.Client = RunnerData.Client
            Data.OrgMSG = MSG
            Data.Author = MSG.author
            Data.Guild = MSG.guild
            Data.Content = MSG.content
            Data.Member = MSG.member
            Data.PreMSG = PreMSG
            Data.Wait = Wait
            Data.TableToString = TableToString
    
            --MSG:reply({content = "test", tts = true})
            
            local CommandFound = false
            
            
            for i, v in pairs(Commands) do
                if v.Command == Command then
                    v.Function(Data)
                    CommandFound = true
                    break
                else
                    for i, b in pairs(v.Aliases) do
                        if Command == b then
                            v.Function(Data)
                            CommandFound = true
                            break
                        end
                    end
                end
            end
            
            
            if CommandFound then
                
            else
                PreMSG:setContent("Command Not found")
                Wait(1)
                PreMSG:delete()
            end
            
    
            
    
        end
    
        
    end)
end