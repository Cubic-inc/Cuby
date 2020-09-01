return function(Data)

    local Client = Data.Client
    local Prefix = Data.Prefix
    local Wait = Data.Libs.Code.Wait
	local TableToString = Data.Libs.Code.TableToString
    local Commands = Data.Libs.Tables.Commands
    local WebHooks = Data.Libs.Tables.WebHooks
	
    local Coro = require("coro-http")
    local Json = require("json")
    local LoggerLink = WebHooks.Logger

    Client:on("voiceChannelJoin", function(Member, Channel)
        
		
		
        local ToSend = {embeds = {
            {
                title = "Channel Join",
				
				author = {
					name = Member.user.name,
					icon_url = Member.user.avatarURL
				},
				
				fields = {
				
					{name = " ⠀ ", value = " ⠀ "},
					{name = "Channel:", value = Channel.name},
					{name = " ⠀ ", value = " ⠀ "},
					{name = "Time", value = os.date("%c")},
				
				}
            }
        }}
		
		local Encoded = Json.stringify(ToSend)

        coroutine.wrap(function()
            local Data = {content = "test"}
            local res, body = Coro.request("POST", LoggerLink, {{"Content-Type", "application/json"}}, Encoded)
        
        end)()

    end)



end