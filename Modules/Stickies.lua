return function ()
    
    local Client = _G.Client
    local Database = require("Save"):GetDatabase("stickies")

    local BaseSticky = {
        ChannelId = "0",
        Enable = false,
        Sticky = {
            Title = "Sticky",
            Description = "Sticky Desc",
            ShowTopic = false
        },
        LastSent = nil
    }


    Client:on("messageCreate", function (MSG)
    
        local Sticky = Database:GetAsync(MSG.channel.id)-- or BaseSticky
        local AnotherMSG = false
        local AnotherMSGFunc



        if MSG.author.id == Client.user.id and MSG.embed and MSG.embed.footer and MSG.embed.footer.text == "Sticky set by admin" then return end

        if Sticky and Sticky.Enable then

            AnotherMSGFunc = Client:on("messageCreate", function (NextMSG)
                if NextMSG.channel.id == MSG.channel.id then
                    AnotherMSG = true
                    Client:removeListener("messageCreate", AnotherMSGFunc)
                end
            end)

            Wait(12 * 1000)

						if not AnotherMSG then
							MSG.channel:broadcastTyping()
						end

						Wait(3 * 1000)

            if not AnotherMSG then

                if Sticky.LastSent then
                    local LastSent = MSG.channel:getMessage(Sticky.LastSent)
                    if LastSent then
                        LastSent:delete()
                    end
                end

                local Embed = {
                    title = Sticky.Sticky.Title,
                    description = Sticky.Sticky.Description,
                    fields = {{name = "Topic", value = MSG.channel.topic or "No Topic set :("}},
                    footer = {text = "Sticky set by admin", icon_url = "https://images.ctfassets.net/7cqe14fu3dhm/3xqGPO9PjQT6lGCcNhTrxn/d4703bcf79d489d17c706dc3d8e8a3fe/hoofd_kleur.png"},
                    color = 0xffff00
                }

                

                if not Sticky.Sticky.ShowTopic then
                    Embed.fields = nil
                end

                local StickySent = MSG:reply(
                    {
                        embed = Embed
                    }
                )

                Sticky.LastSent = StickySent.id

                Database:PostAsync(MSG.channel.id, Sticky)
            end

        end
    
    end)

end