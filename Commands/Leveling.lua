return function ()

	local Client = _G.Client
  local Slash = _G.Slash
  local SaveCommand = _G.SaveCommand
  local Format = _G.Format

	local LevelModule = require("Level")

	local StatsCommand = Slash.new("stats", "Get your money and level | Access for everyone!")

	StatsCommand:callback(function(IA, Params, Cmd)

		IA:reply(
			Format(
			"%s, \nYou are level **%s**!\nWith **%s** XP!\nAnd **%s**$!",
			IA.member.user.pingString,
		 	LevelModule.GetLevel(IA.member),
			LevelModule.GetXp(IA.member),
			LevelModule.GetMoney(IA.member)
			), true, false)

	end)

	SaveCommand(StatsCommand)

end