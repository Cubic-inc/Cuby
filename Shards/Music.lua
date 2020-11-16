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
    JoinCommand:SetName("join")
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
    PlayCommand:SetName("play")
    local LinkArg = PlayCommand:NewArg()
    LinkArg:SetName("Link")
    local DebugArg = PlayCommand:NewArg()
    DebugArg:SetName("Debug?")

    PlayCommand:SetFunction(function(MSG, Args, Raw)

        local MSG = GetMusicMessage(MSG)
        local Member = MSG.member

        ArgsTwoString = Args[2] or ""

        function DebugReply(String)
            if string.lower(ArgsTwoString) == "true" then
                MSG:reply(String)
            end
        end

        if not Member.voiceChannel then
            MSG:reply("Must be in a voice channel to use this command")
            DebugReply("Command Exit")
            return
        end

        if not MusicFuncs.CorrectUrl(Args[1]) then
            
            MSG:reply("First argument must be a youtube link!")
            DebugReply("Command Exit")
            return
        end

        if not VoiceConnect then
            MSG:reply("Not Connected!\nConnecting...")
            DebugReply("Connecting to discord servers")
            DebugReply("Connecting to channel")
            VoiceConnect = Member.voiceChannel:join()
            MSG:reply("Joined!")
            DebugReply("Joined channel!")
            
        end
        
        --print(Args[1])

        local Check, Title = MusicFuncs.GetStream(Args[1], MSG, string.lower(ArgsTwoString) == "true")

        print(Title)

        if Check == true then

            VoiceConnect:stopStream()
            DebugReply("Stopping current stream")
            MSG:reply("Playing Song!! :musical_note: ")
            DebugReply("Playing file")
            MClient:setGame({name = Title, type = 2})
            VoiceConnect:playFFmpeg("CurrentPlayingFile.mp3")
            MClient:setGame({name = "Music", type = 2})

            
        else
            MSG:reply("Unknown error occured whilst downloading file..")
        end

        
    end)

    local StopCommand = Handler.New()
    StopCommand:SetName("skip")
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