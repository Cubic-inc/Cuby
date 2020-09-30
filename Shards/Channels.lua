return function(Data)
	local Client = Data.Client

	local ChannelsCat = Client:getChannel("760402829038583810")
	local JoinChannel = Client:getChannel("760402794066083871")

	local Channels = Data.GlobalValues.Channels

	


	Client:on("voiceChannelJoin", function(Member, Channel)
		if Channel == JoinChannel and not Channels[Member.id] then
			local TextChannel = ChannelsCat:createTextChannel(Member.name .. "\'s Text Channel")
			local VoiceChannel = ChannelsCat:createVoiceChannel(Member.name .. "\'s Voice Channel")

			local Perms = TextChannel:getPermissionOverwriteFor(Member)
			Perms:allowPermissions(0x00000800, 0x00001000, 0x00002000, 0x00000400)

			TextChannel:send({content = "Welkom bij je eigen kanaal alleen jij kunt dit zien.", 
			embed = {
						title = "Welkom",
						description = "Je kan de volgende commando's gebruiken:\n**!addmember\n!removemember\n!joinrequest\n!acceptrequest\n!declinerequest\n!lockchannel\n!unlockchannel**",}
			})

			Channels[Member.id] = {["Text"] = TextChannel, ["Voice"] = VoiceChannel, Locked = false}

			Member:setVoiceChannel(VoiceChannel.id)
		elseif Channel == JoinChannel and Channels[Member.id] then
			Member:setVoiceChannel(Channels[Member.id].Voice.id)
		end
	end)

	Client:on("voiceChannelLeave", function(Member, Channel)
		if not Member or not Channel then return end

		if Channels[Member.id] and Channel == Channels[Member.id].Voice and Channels[Member.id].Locked == false then
			if Channels[Member.id].Text then
				Channels[Member.id].Text:delete()
			end
			if Channels[Member.id].Voice then
				Channels[Member.id].Voice:delete()
			end

			Channels[Member.id] = nil
		end
	end)
	
	for i, v in pairs(ChannelsCat.textChannels) do
		v:delete()		
	end

	for i, v in pairs(ChannelsCat.voiceChannels) do
		for i, b in pairs(v.connectedMembers) do
			b:setVoiceChannel(JoinChannel.id)
		end

		v:delete()		
	end
end