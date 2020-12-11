-- The variable below is the ID of the script you've created, you won't need
-- to enter any information other than this.

local Link = "https://Database.scriptitwithcod.repl.co"


local Coro = require("coro-http")
local Json = require("json")
local Wait = require("./Wait.lua")
local Query = require("querystring")

local Module = {}

local Token = require("../Tokens").Save or os.getenv("SAVE")

local Cache = _G.SaveCache

if not Cache then
	Cache = {}
	_G.SaveCache = Cache
end


function DoGet(Store, Key)
	local URL = Link .. "/" .. Token .. "/get/" .. Store .. "/" .. Key 

	local Res, Body = Coro.request("GET", URL)
	Data = Json.parse(Body)

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

end

function DoPost(Store, Key, data)
	local URL

	if type(data) == "table" then
		URL = Link .. "/" .. Token .. "/save/" .. Store .. "/" .. Key 
	else
		URL = Link .. "/" .. Token .. "/save/" .. Store .. "/" .. Key 
	end

	local StringData = Query.urlencode(Json.encode(data))

	Res, Body = Coro.request("POST", URL, {{"Content-Type", "application/json"}}, StringData)
	Data = Json.parse(Body)

	if Data.status == "ok" then
		Cache[Store][Key] = data
		return true
	else
		print("Database error:", Data.error)	
		return false
	end
end

function DoGetStore(Store, Key)
	local URL = Link .. "/" .. Token .. "/getstore/" .. Store

	local Res, Body = Coro.request("GET", URL)
	Data = Json.parse(Body)

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

end

function Module:GetDatabase(Store)
	local database = {}

	local Store = string.lower(Store)

	function database:_tostring()
		return "Database: " .. Store
	end

	if not Cache[Store] then
		Cache[Store] = {}
	end

	function database:PostAsync(key, value)
		Cache[Store][key] = value

		return DoPost(Store, key, value)
	end

	function database:GetStoreAsync(key)
		return DoGetStore(Store)
	end

	function database:GetAsync(key)
		if Cache[Store][key] then
			return Cache[Store][key]
		else
			return DoGet(Store, key)
		end
	end
	return database
end

return Module