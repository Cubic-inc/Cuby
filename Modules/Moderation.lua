return function ()

    local LastMSGs = {}

    _G.LastMSGs = LastMSGs
    local WarnModule = require("Warn")

    Client:on("messageCreate", function(MSG)
        if MSG.channel.id == "685066367526895658" or MSG.channel.id == "759717939631882280" or MSG.channel.id == "758701430642311188" or MSG.channel.id == "775694351141175306" then --[[print("Channel ignored")]] return end
        if MSG.author.bot then --[[print("no bot users")]] return end

				if not MSG.guild then return end

       Wait(200)
        
        if not LastMSGs[MSG.author.id] then
            LastMSGs[MSG.author.id] = {Content = "", Times = 0}
        end
        
        

        if LastMSGs[MSG.author.id].Content == MSG.content and not MSG.content == "" then
						local Notice = MSG:reply(MSG.author.pingString .. " Do not repeat messages!")
            MSG:delete()
            LastMSGs[MSG.author.id] = {Content = MSG.content, Times = LastMSGs[MSG.author.id].Times + 1}

						Wait(3000)
						Notice:delete()
            
        else
            LastMSGs[MSG.author.id].Times = 0
        end

        if LastMSGs[MSG.author.id].Times >= 3 then
            WarnModule.Create(MSG.channel, MSG.author, "Repeating messages")
        end

        LastMSGs[MSG.author.id].Content = MSG.content
        --print(LastMSGs[MSG.author.id].Times)
    end)
	
	local SwearWords = {
        "rko",
        "kanker",
        "tering",
        "klootzak",
        "kutwijf",
        "kuttenkop",
        "loser",
        "lummel",
        "piemel",
        "kaashoer",
        "hoer",
        "mongool",
        "klootviool",
        "eikel",
        "kankerhoer",
        "kankerhond",
        "kankerlijder",
        "kankerlijer",
        "kankernicht",
        "kapsoneslijer",
        "mietje",
        "bitch",
        "kutwijf",
        "kutvent",
        "kontkruiper",
        "kontneuker",
        "https://cdn.discordapp.com/attachments/768526368173981707/769643539683999764/image0.jpg",
        "bytecore",
				"thijmen",
				"menthij",
				"tijmen",
				"bitecore",
				"byte core"

    }



    Client:on("messageCreate", function(MSG)
        if MSG.author.bot then --[[print("no bot users")]] return end
				if not MSG.guild then return end
        
        local Found = false

        for i, v in pairs(SwearWords) do
            if string.find(string.lower(MSG.content), v) then
                Found = true
                break
            end
        end


        if Found == true then
            local Notice = MSG:reply(MSG.author.pingString .. " a swearword was found in your message and it was deleted\nYou may get warned if you continue")
            MSG:delete()

						Wait(5000)
						Notice:delete()
        end

    end)

    coroutine.wrap(function ()
        local MuteBase = require("Save"):GetDatabase("mutes")
        local MuteModule = require("Mute")

        while true do
            

            local CurrentMutes = MuteBase:GetStoreAsync()
            local CurrentTimeSecs = Date():toSeconds()

            --print("It's currently", CurrentTimeSecs, "in seconds")


            for i, v in pairs(CurrentMutes) do
                if v.EndsAt <= CurrentTimeSecs then
                    MuteModule.UnMute(Client:getUser(i))
                end
            end

            Wait(60 * 1000)
        end
    end)()



end
