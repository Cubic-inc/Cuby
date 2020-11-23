return function(Data)

	local WebHooks = require("Tables/WebHooks").Pingers

	while false do

		require("Code/Wait")(3000)

		for i, v in pairs(WebHooks) do
			require("Code/PostWebhook")({content = "<@603924528296361984>"}, v)
			require("Code/Wait")(1000)
		end

	end

end