return function(Data)

    local Discordia = require("discordia")

    local Client = Data.Client
    local Prefix = Data.Prefix
    local Wait = Data.Libs.Code.Wait
	local TableToString = Data.Libs.Code.TableToString
    local Commands = Data.Libs.Tables.Commands
    local WebHooks = Data.Libs.Tables.WebHooks

    local PostWebhook = Data.Libs.Code.PostWebhook
	
    local Coro = require("coro-http")
    local Json = require("json")
    local LoggerLink = WebHooks.Logger

    Client:on("voiceChannelJoin", function(Member, Channel)
        
		print("join")
		
        local ToSend = {
            content = "",
            embeds = {
            {
                title = "Channel Join",
				
				author = {
					name = Member.user.name,
					icon_url = Member.user.avatarURL
				},
				
				fields = {
				
					{name = " ⠀ ", value = " Channel: "},
					{name = Channel.name, value = " ⠀ "},
					{name = " ⠀ ", value = " Time: "},
					{name = os.date("%c"), value = " ⠀ "},
				
                },
                
                color = 0x00FF00,
            }
        }}
		
        local one, two = PostWebhook(ToSend, LoggerLink)
        --print(one)
        --print(two)

    end)

    Client:on("voiceChannelLeave", function(Member, Channel)
        
		print("Leave")
		
        local ToSend = {
            content = "",
            embeds = {
            {
                title = "Channel Leave",
				
				author = {
					name = Member.user.name,
					icon_url = Member.user.avatarURL
				},
				
				fields = {
				
					{name = " ⠀ ", value = " Channel: "},
					{name = Channel.name, value = " ⠀ "},
					{name = " ⠀ ", value = " Time: "},
					{name = os.date("%c"), value = " ⠀ "},
				
                },
                
                color = 0xFF0000
            }
        }}
		
        local one, two = PostWebhook(ToSend, LoggerLink)
        --print(one)
        --print(two)

    end)

end