return function(Data)

    local Handler = Data.CommandHandler
    local Base = require("Code/Save"):GetDatabase("tickets")
    

    local Client = _G.Client
    local ModClient = _G.ModClient

		local Guild

		while not Guild do
			Guild = ModClient:getGuild("657227821047087105")
			require("timer").sleep(1500)
		end

		local ModCat

		while not ModCat do
			ModCat = Guild:getChannel("780327205104123925")
			require("timer").sleep(1500)
		end

		function GetUserFromChannel(Channel)

			local Store = Base:GetStoreAsync()

			local User = nil
			for i, v in pairs(Store) do
				if v.Channel == Channel.id then
					return i
				end
			end

			return nil
		end

		--print(GetUserFromChannel({id = "780372137961586708"}))

    local Channel = ModClient:getChannel("777910517058240522")

    ModClient:on("messageCreate", function(MSG)
        
        if MSG.guild then return end
        if MSG.author.bot then return end

        local Tick = Base:GetAsync(MSG.author.id)

        if not Tick then
            MSG:reply({embed = {
                title = "Opening a new ticket with your id: " .. MSG.author.id,
                description = "Please wait until a moderator gets in contact with you",
								color = 0x7289DA
            }})

            local NewChannel = ModCat:createTextChannel(MSG.author.tag)

						NewChannel:send({embed = {
							title = "New thread created",
							author = {
								name = MSG.author.username,
								icon_url = MSG.author.avatarURL
							},
							description = "By " .. MSG.author.tag,
							color = 0x7289DA
						}})

						NewChannel:send({embed = {
                author = {
									name = "First message from " .. MSG.author.tag,
									icon_url = MSG.author.avatarURL
                },
                description = MSG.cleanContent,
								color = 0xf5c542
            }})

            local TicketData = {
                From = MSG.author.id,
								Channel = NewChannel.id
            }

            Base:PostAsync(MSG.author.id, TicketData)

        else
            local ReplyChannel = Guild:getChannel(Tick.Channel)
						
						ReplyChannel:send({embed = {
                author = {
									name = "New Reply From " .. MSG.author.tag,
									icon_url = MSG.author.avatarURL
                },
                description = MSG.cleanContent,
								color = 0xf5c542
            }})

        end

        
    
    end)

		local ReplyCommand = Handler.New()
		ReplyCommand:SetName("reply")
		ReplyCommand:SetMinPerm("Mod")
		ReplyCommand:SetGroup("ModMail")
		ReplyCommand:SetFunction(function(MSG, Args, Raw)
		
			if GetUserFromChannel(MSG.channel) then
				local User = ModClient:getUser(GetUserFromChannel(MSG.channel))

				User:send({embed = {

          author = {
						name = "New Reply From " .. MSG.author.tag,
						icon_url = MSG.author.avatarURL
          },

        	description = table.concat(Raw, " "),

					color = 0x48f542

        }})

				ModClient:getChannel(MSG.channel.id):send({embed = {

          author = {
						name = "Reply sent by " .. MSG.author.tag,
						icon_url = MSG.author.avatarURL
          },

        	description = table.concat(Raw, " "),

					color = 0x48f542

        }})

				MSG:delete()

			else
				MSG:reply("This command can only be used in `modmail` channels!")
			end

		end)

		local CloseCommand = Handler.New()
		CloseCommand:SetName("CloseThread")
		CloseCommand:SetMinPerm("Mod")
		CloseCommand:SetGroup("ModMail")
		CloseCommand:SetFunction(function(MSG, Args, Raw)
		
			if GetUserFromChannel(MSG.channel) then
				local User = ModClient:getUser(GetUserFromChannel(MSG.channel))

				User:send({embed = {

          author = {
						name = "Thread closed by " .. MSG.author.tag,
						icon_url = MSG.author.avatarURL
          },

        	description = table.concat(Raw, " "),

					color = 0xf54242

        }})

				MSG.channel:delete()
				Base:PostAsync(User.id, nil)

			else
				MSG:reply("This command can only be used in `modmail` channels!")
			end

		end)

		local NewCommand = Handler.New()
		NewCommand:SetName("NewThread")
		NewCommand:SetMinPerm("Admin")
		NewCommand:SetGroup("ModMail")
		local Arg = NewCommand:NewArg()
		Arg:SetName("To open")
		Arg:SetType("Member")
		Arg:SetReq(true)
		NewCommand:SetFunction(function(MSG, Args, Raw)

			local User = ModClient:getUser(Args[1].user.id)
		
			local Tick = Base:GetAsync(User.id)

			if Tick then MSG:reply(User.tag .. " already has a thread") return end

			MSG:reply("Creating new thread for " .. User.tag)

			local NewChannel = ModCat:createTextChannel(User.tag)

			NewChannel:send({embed = {
				title = "New thread created",
				author = {
					name = MSG.author.username,
					icon_url = MSG.author.avatarURL
				},
				description = "By " .. MSG.author.tag,
				color = 0x7289DA
			}})

			User:send({embed = {
				title = "A new thread got created with your id: " .. User.id,
				author = {
					name = "By " .. MSG.author.username,
					icon_url = MSG.author.avatarURL
				},
			}})

      local TicketData = {
        From = MSG.author.id,
				Channel = NewChannel.id
      }

      Base:PostAsync(User.id, TicketData)

		end)

end