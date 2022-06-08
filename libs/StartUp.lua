return function()
    print()

    print("Requirering Discordia")
    local Discordia = require("discordia")

    print("Requirering Discordia-Slash")
    local Slash = require("discordia-slash")
    Slash.constructor()

    print("Getting Client and Injecting Slash")
    local Client = Discordia.Client()
    Client:useSlashCommands()

    print("Getting Configuration")
    local Config = require("../Config.lua")

    local Date = Discordia.Date

    local DevMode = Config.IsDevMode
    CassieRunning = false

		print("\n\n\n")

		Client:info("░█████╗░██╗░░░██╗██████╗░██╗░░░██╗")
		Client:info("██╔══██╗██║░░░██║██╔══██╗╚██╗░██╔╝")
		Client:info("██║░░╚═╝██║░░░██║██████╦╝░╚████╔╝░")
		Client:info("██║░░██╗██║░░░██║██╔══██╗░░╚██╔╝░░")
		Client:info("╚█████╔╝╚██████╔╝██████╦╝░░░██║░░░")
		Client:info("░╚════╝░░╚═════╝░╚═════╝░░░░╚═╝░░░")

		print("\n\n\n")

    Client:once("ready", function()
        print("Client Ready")
        print()
        print("Setting ENV vars")

        local Guild = Client:getGuild(Config.GuildId)
        local MuteRole = Guild:getRole(Config.MuteRole)
        local LogChannel = Client:getChannel(Config.LogChannel)
        local Watch = Discordia.Stopwatch()        
        Watch:start()

        local StaffRoles = {}

        for i, v in pairs(Config.Roles) do
            StaffRoles[i] = Guild:getRole(v)
        end

        _G.StaffRoles = StaffRoles
        _G.LogChannel = LogChannel
        _G.Wait = require("timer").sleep

        _G.Guild = Guild
        _G.Discordia = Discordia

        _G.GetVoice = function ()
            return Guild.connection
        end
        
        

        _G.CalcLevel = function (Xp)
            local Count = 50
            return math.max(math.floor(math.log(Xp/Count) / math.log(2.1) + 2), 1) - 1
        end

        _G.MuteRole = Config.MuteRole
        
        _G.Slash = Slash
        _G.Config = Config
        _G.Watch = Watch

				Client:setGame(Config.CurrentGame)

				for i, v in pairs(Config.OtherTokens) do
					local ThatClient = Discordia.Client({logLevel = 1})

					ThatClient:run("Bot " .. v)
				end


        print("DONE Starting")
    end)
    
    _G.Client = Client
    _G.Format = string.format
    _G.Date = Date
    _G.GetTimeStamp = function() return Date():toISO() end
    _G.SaveCommand = function (Command) _G.Guild:slashCommand(Command:finish()) end
    _G.DevMode = DevMode

    local UserIs = function (Inter, Type)

        local Member = _G.Guild:getMember(Inter.member.user.id)

        local Roles = _G.StaffRoles

        local HasRole = Inter:memberHasRole(Roles[Type].id)

        --print(Roles[Type].name)

        --print(HasRole)

        if not HasRole then
            Inter:reply("Only **__" .. Type .. "__**'s can use this command", true, true)
        end

        return HasRole
    end

    _G.UserIs = UserIs

    Client:run("Bot " .. Config.Token)
    
    coroutine.wrap(function ()
        --Client:waitFor("ready")
        Client:waitFor("slashCommandsReady")
        
        Client:emit("allReady")
        --print("ALL READY FIRED")
    end)()
    
    
   
    
    coroutine.wrap(function ()
        if DevMode then
            Client:once("slashCommandsReady", function ()
                local All = {} --_G.Guild:getSlashCommands()

                for i, v in pairs(All) do
                    v:delete()
                    print("del")
                end
            end)

        end 
    end)
    

    
end