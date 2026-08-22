return function ()

    local Slash = _G.Slash
    local SaveCommand = _G.SaveCommand
    local Client = _G.Client
    local OptionType = Slash.enums.optionType
    local FS = require("fs")

    function Split (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
    end
    
    local Replacers = {
            a = "_a",
            b = "_b",
            c = "_c",
            d = "_d",
            e = "_e",
            f = "_f",
            g = "_g",
            h = "_h",
            i = "_i",
            j = "_j",
            k = "_k",
            l = "_l",
            m = "_m",
            n = "_n",
            o = "_o",
            p = "_p",
            q = "_q",
            r = "_r",
            s = "_s",
            t = "_t",
            u = "_u",
            v = "_v",
            w = "_w",
            x = "_x",
            y = "_y",
            z = "_z",

            mtfa = "a",
            mtfb = "b",
            mtfc = "c",
            mtfd = "d",
            mtfe = "e",
            mtff = "f",
            mtfg = "g",
            mtfh = "h",
            mtfi = "i",
            mtfj = "j",
            mtfk = "k",
            mtfl = "l",
            mtfm = "m",
            mtfn = "n",
            mtfo = "o",
            mtfp = "p",
            mtfq = "q",
            mtfr = "r",
            mtfs = "s",
            mtft = "t",
            mtfu = "u",
            mtfv = "v",
            mtfw = "w",
            mtfx = "x",
            mtfy = "y",
            mtfz = "z",

        }


    local CassieCommand  = Slash.new("cassie", "Play C.A.S.S.I.E | Admin only!")

    CassieCommand:option("text", "Text to parse", OptionType.string, true)

    CassieCommand:callback(function (Inter, Params, Cmd)

        if not UserIs(Inter, "Admin") then
			return
		end

        local Text = string.lower(Params.text)

        local ParsedText = Split(Text, " ")

        if not Inter.member.voiceChannel then
            Inter:reply("You are not in a voicechannel!", true, true)
            return
        end

        --[[if VoiceConnect then
            Inter:reply("Im already connected!", true, true)
            return
        end]]

        

        Inter:ack(true)

        coroutine.wrap(function ()
            local VoiceConnect = Inter.member.voiceChannel:join()

            GetVoice():playFFmpeg("./VoiceData/Data/start.mp3", 100)

            for i, v in pairs(ParsedText) do

                local FileName = Replacers[v] or v

                local Path = "./VoiceData/Cassie/" .. FileName .. ".wav"
                local Does, Error = FS.existsSync(Path)

                if Does then
                    local Time, Two = GetVoice():playFFmpeg(Path)
                    print(Time, Two, v)
                    --Wait(1000)
                    --Wait(Time)
                else
                    Inter:followUp(v .. " Was not found", true)
                end
                
            end

            GetVoice():playFFmpeg("./VoiceData/Data/start.mp3", 100)

            Wait(1000)

            GetVoice():close()
        end)()
        


    end)

    SaveCommand(CassieCommand)
end