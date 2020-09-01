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
        Name = "stop",
        Desc = "Stops bot",
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