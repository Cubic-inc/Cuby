return function(Data)

    local Handler = Data.CommandHandler
    _G.VoiceConnect = nil
    local VoiceConnect = _G.VoiceConnect

    local Client = _G.Client
    local MClient = _G.MClient

    local MusicFuncs = require("Code/MusicFunctions")

    function GetMusicMessage(MSG)
        return MClient:getChannel(MSG.channel.id):getMessage(MSG.id)
    end

    local JoinCommand = Handler.New()
    JoinCommand:SetName("ChannelJoin")
    JoinCommand:SetFunction(function(MSG, Args, Raw)

        local MSG = GetMusicMessage(MSG)

        local Member = MSG.member

        if not Member.voiceChannel then
            MSG:reply("Must be in a voice channel to use this command")
            return
        end

        VoiceConnect = Member.voiceChannel:join()
        MSG:reply("Joined!")
    
    
    end)

    local PlayCommand = Handler.New()
    PlayCommand:SetName("ChannelPlay")
    local LinkArg = PlayCommand:NewArg()
    LinkArg:SetName("Link")
    PlayCommand:SetFunction(function(MSG, Args, Raw)

        local MSG = GetMusicMessage(MSG)
        local Member = MSG.member

        if not Member.voiceChannel then
            MSG:reply("Must be in a voice channel to use this command")
            return
        end

        if not MusicFuncs.CorrectUrl(Args[1]) then
            
            MSG:reply("First argument must be a youtube link!")
            return
        end

        if not VoiceConnect then
            MSG:reply("Not Connected!\nConnecting...")
            VoiceConnect = Member.voiceChannel:join()
            MSG:reply("Joined!")
            
        end
        
        --print(Args[1])

        local Stream = MusicFuncs.GetStream(Args[1])

        if Stream == true then

            VoiceConnect:stopStream()
            MSG:reply("Playing Song!! :musical_note: ")

            VoiceConnect:playFFmpeg("CurrentPlayingFile.mp3")

            
        else
            MSG:reply("Unknown error occured whilst downloading file..")
        end

        
    end)

    local StopCommand = Handler.New()
    StopCommand:SetName("ChannelStop")
    StopCommand:SetFunction(function(MSG, Args, Raw)

        local MSG = GetMusicMessage(MSG)
        local Member = MSG.member

        if not VoiceConnect then
            MSG:reply("Not Connected!")
            return           
        end

        VoiceConnect:stopStream()
    end)

end