return {

    {
        Name = "ping",
        Desc = "Pong",
        Aliases = {"test"},
        Function = function(Data)
            Data.PreMSG:setContent("Pong")
        end

    },

    {
        Name = "setcurrentping",
        Desc = "Set the ping",
        Aliases = {"setping"},
        Function = function(Data)
            --print(Data.ShardData.Libs.Code.TableToString(Data.OrgMSG.mentionedUsers.first.username))

            local Mentioned = Data.Mentioned
            print(#Mentioned)
            print(Data.cleanContent)
            --print(Data.ShardData.Libs.Code.TableToString(Data.Mentioned))
            if Mentioned[1] then
                Data.PreMSG:setContent("Set ping to user: " .. tostring(Mentioned[1].name))
                print(Mentioned[1].tag)
                Data.ShardData.CurrentPinging = Mentioned[1].id
            else
                Data.PreMSG:setContent("Set ping to: nil")
            end
            
            --Data.ShardData.CurrentPinging = 533536581055938580
	   
        end

    },
	
    {
    Name = "stop",
    Desc = "Stops bot",
	Enabled = false,
        Aliases = {},
        Function = function(Data)
            Data.PreMSG:setContent("Stopping bot")
			
			Data.MusicClient:getChannel("658677095534428166"):leave()
			
			Data.Client:stop()
			Data.MusicClient:stop()
			os.Exit()
        end

    }



}