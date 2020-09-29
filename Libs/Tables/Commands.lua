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
	    if Data.OrgMSG.mentionedUsers[1] then
                Data.PreMSG:setContent("Set ping to: " .. Data.OrgMSG.mentionedUsers[1])
		Data.ShardData.CurrentPinging = Data.OrgMSG.mentionedUsers[1].id
	    else
		Data.PreMSG:setContent("Set ping to: nil")
	    end
	   
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