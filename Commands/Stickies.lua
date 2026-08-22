return function ()
    
    local Client = _G.Client
    local Slash = _G.Slash
    local SaveCommand = _G.SaveCommand
    local OptionType = Slash.enums.optionType
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

    
    local StickyCommand = Slash.new("sticky", "Create a sticky for the current channel.")

    local EnableOption = StickyCommand:suboption("enable", "Enable the sticky | Head Admin only!")
    local DisableOption = StickyCommand:suboption("disable", "Disable the sticky | Head Admin only!")

    EnableOption:option("title", "Title for the sticky", OptionType.string, true)
    EnableOption:option("description", "Description for the sticky", OptionType.string, false)
    EnableOption:option("showtopic", "Show the channel topic", OptionType.boolean)

    StickyCommand:callback(function (Inter, Params, Cmd)
        
        if not UserIs(Inter, "Owner") then
			return
        end
        
        if Params.enable then
            local Title = Params.enable.title
            local Desc = Params.enable.description
            local ShowTopic = Params.enable.showtopic

            local CurrentSticky = Database:GetAsync(Inter.channel.id) or BaseSticky

            CurrentSticky.Enable = true
            CurrentSticky.ChannelId = Inter.channel.id 

            CurrentSticky.Sticky.Title = Title
            CurrentSticky.Sticky.Description = Desc
            CurrentSticky.Sticky.ShowTopic = ShowTopic

            Database:PostAsync(Inter.channel.id, CurrentSticky)

            Inter:reply("Sticky set, it should show up shortly!", true, true)

        elseif Params.disable then

            local CurrentSticky = Database:GetAsync(Inter.channel.id) or BaseSticky

            CurrentSticky.Enable = false
            CurrentSticky.ChannelId = Inter.channel.id 

            Database:PostAsync(Inter.channel.id, CurrentSticky)

            Inter:reply("Done! Sticky disabled! Use `/sticky enable` to reenable it!")

        end

    end)

    SaveCommand(StickyCommand)


end