return function(Data)

    local Handler = Data.CommandHandler
    local Base = require("Code/Save"):GetDatabase("tickets")
    

    local Client = _G.Client
    local ModClient = _G.ModClient

    local Channel = ModClient:getChannel("777910517058240522")

    ModClient:on("messageCreate", function(MSG)
        
        if MSG.guild then return end
        if MSG.author.bot then return end

        local Tick = Base:GetAsync(MSG.author.id)

        if not Tick then
            MSG:reply({embed = {

                title = "Opening a new ticket with your id: " .. MSG.author.id,
                description = "Please wait until a moderator gets in contact with you"

            }})

            local New = Channel:send({embed = {

                author = {
					name = MSG.author.username,
					icon_url = MSG.author.avatarURL
                },

                title = "New ticket incoming with id: " .. MSG.author.id,
                description = MSG.cleanContent,
                footer = {

                    text = "React with ✅ to assing this ticket to you\nReact with ❎ to close this ticket"
                }

            }})

            New:addReaction("✅")
            New:addReaction("❎")

            local TicketData = {
                From = MSG.author.id,
                FirstMessage = MSG.id,
                LastModMessage = New.id,
                Assinged = false,
                AssingedStaff = nil,

            }

            local React = ModClient:on("reactionAdd", function(Reaction, UserID)
                local User = Client:getUser(UserID)


                if User.bot then return end

                if Reaction.emojiHash == "✅" then
                
                    TicketData.AssingedStaff = UserID
                    Base:PostAsync(MSG.author.id, TicketData)

                    MSG:reply({embed = {
                        title = "A staff member was assinged to your ticket\nA reply is coming soon!"
                    }})

                    Channel:send({embed={title = "You are now assinged to this ticket"}})
                    New:clearReactions()

                    Client:removeListener("reactionAdd", React)

                elseif Reaction.emojiHash == "❎" then

                    
                    Base:PostAsync(MSG.author.id, nil)

                    MSG:reply({embed = {
                        title = "A staff member closed your ticket"
                    }})

                    Channel:send({embed={title = "This ticket is now closed"}})
                    New:clearReactions()

                    Client:removeListener("reactionAdd", React)
            
                end

            end)

            Base:PostAsync(MSG.author.id, TicketData)
        else
            local New = Channel:send({embed = {

                author = {
					name = MSG.author.username,
					icon_url = MSG.author.avatarURL
                },

                title = "New reply id: " .. MSG.author.id,
                description = MSG.cleanContent

            }})

            MSG:addReaction("❎")

            New:addReaction("❎")

            local React = ModClient:on("reactionAdd", function(Reaction, UserID)
                local User = Client:getUser(UserID)

                if User.bot then return end

                if Reaction.message.id ~= MSG.id then return end

                if Reaction.emojiHash == "❎" then

                    MSG:reply({embed = {title = "You closed this ticket"}})
                    New:reply({embed = {title = "Ticket closed by user"}})

                    Channel:send({embed={title = "This ticket is now closed"}})

                    Client:removeListener("reactionAdd", React)

                end

            end)
        end

        
    
    end)

end