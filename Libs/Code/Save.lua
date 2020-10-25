-- The variable below is the ID of the script you've created, you won't need
-- to enter any information other than this.

local Link = "https://Database.scriptitwithcod.repl.run"


local Coro = require("coro-http")
local Json = require("json")
local Wait = require("./Wait.lua")
local Query = require("querystring")

local Module = {}

local Token = require("./././Tokens.lua").Save or os.getenv("SAVETOKEN")


function DoGet(Store, Key)
	local URL = Link .. "/" .. Token .. "/get/" .. Store .. "/" .. Key 


	local Res, Body = Coro.request("GET", URL)
	Data = Json.parse(Body)
	--print(Body)
		
	--print(Res, Body)
	if Data.status == "ok" then
		if Data.data then
			return Data.data
		else
			return nil
		end
	else
		print("Database error:", Data.error)	
		return
	end




	--return Data
end

function DoPost(Store, Key, data)
	local URL
	--print(type(data))
	if type(data) == "table" then
		URL = Link .. "/" .. Token .. "/save/" .. Store .. "/" .. Key .. "/" .. Query.urlencode(Json.encode(data))
	else
		URL = Link .. "/" .. Token .. "/save/" .. Store .. "/" .. Key .. "/" .. data
	end
	--print(URL)
	
	local Res, Body = Coro.request("GET", URL)
	Data = Json.parse(Body)
	--print(Body)
	--print(URL)

	

		
	--print(Res, Body)
	if Data.status == "ok" then
		return true
	else
		print("Database error:", Data.error)	
		return false
	end
end

function DoGetStore(Store, Key)
	local URL = Link .. "/" .. Token .. "/getstore/" .. Store

	--print(1)

	local Res, Body = Coro.request("GET", URL)
	Data = Json.parse(Body)
	--print(Body)
	--print(2)
		
	--print(Res, Body)
	if Data.status == "ok" then
		if Data.data then
			--print(3)
			return Data.data
		else
			return nil
		end
	else
		print("Database error:", Data.error)	
		return
	end




	--return Data
end

function Module:GetDatabase(sheet)
	local database = {}
	function database:PostAsync(key, value)
		return DoPost(string.lower(sheet), key, value)
	end

	function database:GetStoreAsync(key)
		return DoGetStore(string.lower(sheet))
	end

	function database:GetAsync(key)
		return DoGet(string.lower(sheet), key)
	end
	return database
end

return Module


