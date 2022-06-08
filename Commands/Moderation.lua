return function ()

    local Client = _G.Client
    local Slash = _G.Slash
    local SaveCommand = _G.SaveCommand
    local Format = _G.Format
    local Query = require("querystring")

    local MuteModule = require("Mute")
    local WarnModule = require("Warn")
    
    local OptionType = Slash.enums.optionType

    local MuteCommand = Slash.new("mute", "Mute a user")

    local EnMute = MuteCommand:suboption("add", "Mute the user | Moderator only!")
    local Unmute = MuteCommand:suboption("remove", "Unmute the user | Moderator only!")

    EnMute:option("User", "User to mute", OptionType.user, true)
    EnMute:option("Time", "Mute Time", OptionType.integer, false):choices(
    {name = "5 Mins", value = 5},
    {name = "15 Mins", value = 15}, 
    {name = "30 Mins", value = 30}, 
    {name = "1 Hour", value = 60}, 
    {name = "2 Hours", value = 120}, 
    {name = "6 Hours", value = 360}, 
    {name = "12 Hours", value = 720},
    {name = "1 Day", value = 1440},
    {name = "1 Week", value = 10080},
    {name = "1 Month", value = 30240})
    EnMute:option("Reason", "Reason for the mute", OptionType.string, false)

    Unmute:option("User", "User to unmute.", OptionType.user, true)

    MuteCommand:callback(function (Inter, Params, Cmd)

        local User
        local Reason
        local Time

        if Params.add then
            User = Params.add.user
            Reason = Params.add.reason or "No reason"
            Time = Params.add.time or 9999999
        elseif Params.remove then
            User = Params.remove.user
        end

        if not _G.UserIs(Inter, "Moderator") then
            return
        end

        

        if Params.add then
            if MuteModule.Is(User) then
                Inter:reply("User is already muted!", true, true)
                return
            end

            MuteModule.Mute(User, Reason, Inter.channel, Time)
        elseif Params.remove then
            if not MuteModule.Is(User) then
                Inter:reply("User is not muted!", true, true)
                return
            end
            
            MuteModule.UnMute(User, Inter.channel)
        end
    end)

    SaveCommand(MuteCommand)

    local WarnCommand = Slash.new("warn", "Warn a user.")
    

    local Warn = WarnCommand:suboption("create", "Warn a user | Moderator only!")
    Warn:option("User", "Member to warn", OptionType.user, true)
    Warn:option("Reason", "Reason for the warn", OptionType.string, false)

    local GetWarn = WarnCommand:suboption("get", "Get a warn | Moderator only!")

    GetWarn:option("User", "Get a users warns", OptionType.user, true)
    GetWarn:option("WarnId", "Get by warn id", OptionType.user, false)

    local RemoveWarn = WarnCommand:suboption("remove", "Remove a warn | Moderator only!")
    RemoveWarn:option("User", "Member to warn", OptionType.user, true)
    RemoveWarn:option("Warnid", "warnId.", OptionType.string, false)

    WarnCommand:callback(function(Inter, Params, Cmd)

        if not _G.UserIs(Inter, "Moderator") then
            return
        end

        Inter:ack(true)

        if Params.create then
            local User = Params.create.user 
            local Reason = Params.create.reason 

            WarnModule.Create(Inter.channel, User, Reason)
        elseif Params.get then
            local User = Params.get.user 
            local WarnId = Params.get.warnid 

            if WarnId then
                local WarnData = WarnModule.Get(WarnId)

                if WarnData then
                    local Embed = {
                        title = User.name .. "'s Warnings",
                        fields = {
                                    {
                                        name = "**Warning id: " .. WarnData.Id .. "**",
                                        value = "Reason: `" .. WarnData.Reason .. "`\nLink: [Message](" .. Query.urldecode(WarnData.Link) .. ")",
                                        inline = true
                        }}
                    }
                else
                    Inter:followUp("That warn was not found!", true, true)
                end
            else
                local WarnData = WarnModule.GetUserWarns(User)

                local Embed = {
                    title = User.name .. "'s Warnings",
                    fields = {}
                }

                local Query = require("querystring")
                for i, v in pairs(WarnData) do
                    local Field = {
                        name = "**Warning id: " .. v.Id .. "**",
                        value = "Reason: `" .. v.Reason .. "`\nLink: [Message](" .. Query.urldecode(v.Link) .. ")",
                        inline = true
                    }
                    table.insert(Embed.fields, Field)
                end
                
                Inter:followUp({embeds = {Embed}})
            end
        elseif Params.remove then
            local User = Params.remove.user 
            local WarnId = Params.remove.warnid 

            if WarnId then
                Inter:followUp("Removed " .. WarnId)
                WarnModule.RemoveWarn(WarnId)
            else
                Inter:followUp("Done, removed " .. User.user.tag .. " Warns.")
                WarnModule.ClearWarns(User)
            end
        end

        
    end)

    SaveCommand(WarnCommand)


end