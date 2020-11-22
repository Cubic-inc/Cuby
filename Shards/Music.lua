return function(Data)

    local Handler = Data.CommandHandler
    _G.VoiceConnect = nil
    local VoiceConnect = _G.VoiceConnect

    local Debug = false
    

    local Client = _G.Client
    local MClient = _G.MClient
    local CommandChannel = nil

    while not CommandChannel do
        CommandChannel = MClient:getChannel("685066367526895658")
        require("timer").sleep(1500)
    end
    --print(CommandChannel)

    local Queue = {}

    local MusicFuncs = require("Code/MusicFunctions")

    function Next()
        if Queue[1] then
            VoiceConnect:stopStream()
            CommandChannel:send("Downloading song <a:loading:667069786005569536>")
            local Check, Title = MusicFuncs.GetStream(Queue[1].Link, CommandChannel, Debug)
            CommandChannel:send("Downloaded song: `" .. Title .. "`")

            if Check then 
                MClient:setGame({name = Title, type = 2})

                VoiceConnect:playFFmpeg("CurrentPlayingFile.mp3")

                MClient:setGame({name = "Music", type = 2})
                table.remove(Queue, 1)
                if Queue[2] then
                    Next()
                end
            else
                CommandChannel:send("Error")
            end
            
        else
            return
        end
    end

    function Add(Link, Title)
        table.insert(Queue, {Link = Link, Title = Title})
        CommandChannel:send("Added to queue!")
        if #Queue == 1 then
           Next() 
        end
    end

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
        local Correct, NewUrl = MusicFuncs.CorrectUrl(Args[1])

        ArgsTwoString = Args[2] or ""

        function DebugReply(String)
            if string.lower(ArgsTwoString) == "true" then
                MSG:reply(String)
            end
        end

        DebugReply("Debugging is enabled!")

        if not Member.voiceChannel then
            MSG:reply("Must be in a voice channel to use this command")
            DebugReply("Command Exit")
            return
        end

        if not Correct then
            
            MSG:reply("First argument must be a youtube link!")
            DebugReply("Command Exit")
            return
        end

        if not VoiceConnect then

            MSG:reply("Not Connected!\nConnecting...")
            VoiceConnect = Member.voiceChannel:join()
            MSG:reply("Joined!")
            
        end
        
        --print(Args[1])

        

        Add(NewUrl)

        

        
    end)

    local StopCommand = Handler.New()
    StopCommand:SetName("skip")
    StopCommand:SetFunction(function(MSG, Args, Raw)

        local MSG = GetMusicMessage(MSG)
        local Member = MSG.member

        if not Member.voiceChannel then
            MSG:reply("Must be in a voice channel to use this command")
            return
        end

        if not VoiceConnect then
            MSG:reply("Not Connected!")
            return           
        end

        Next()
    end)

end