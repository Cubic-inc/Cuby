return function()

	local Pingers = require("Tables/WebHooks").Pingers

	return nil

	while true do
		require("Code/Wait")(3000)
		for i, v in pairs(Pingers) do
			require("Code/Wait")(1000)
			require("Code/PostWebhook")({content = "<@435074851485515776> <@661584870560235530>"} , v)
		end
	end

end