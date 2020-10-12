-- The variable below is the ID of the script you've created, you won't need
-- to enter any information other than this.

local scriptId = "AKfycbyxt-m0JKxrvY2dxm4LdTLK_5wvv_Xusdb9WQ0qRhZKU4Tk4kkA"
--local scriptId = "https://script.googleusercontent.com/macros/echo?user_content_key=L4rWDN4WqvVaSiK7wpsjA4FG2O9_IClggdgSZLMv750WyRN0iu3-c1z_Jc_M70mpXZZ-G3GCH27e1BN0Nqha9RflYA-OjYtYm5_BxDlH2jW0nuo2oDemN9CCS2h10ox_1xSncGQajx_ryfhECjZEnEDFO6BPtWYgAEBVbzJw3TocFXW2Z6yyWGR6W-GpumW2kwp8gGCltIGTrFQZa9DWDCkahCW402zG&amp;lib=MciwrQ4z5YUXuTcC_uw0F9z54jfneNAvo"

-- Touch anything below and you'll upset the script, and that's not a good thing.

local url = "https://script.google.com/macros/s/" .. scriptId .. "/exec"

local Coro = require("coro-http")
local Json = require("json")
local Wait = require("./Wait.lua")
local Query = require("querystring")

local Module = {}




function DoGet(sheet, key)
	local Link = url .. "?sheet=" .. sheet .. "&key=" .. key

	

	local Res, Body = Coro.request("GET", Link)
	Data = Json.parse(Body)
		
	print(Res, Body)
	if Data.result == "success" then
		return Data.value
	else
		print("Database error:", Data.error)	
	end




	--return Data
end

--[[
function DoPost(sheet, key, data)
	local SendData = Json.encode(data)

	local Link = url, "sheet=" .. sheet .. "&key=" .. key .. "&value=" .. SendData
	local Res, Body = Coro.request("POST", url, {{"Content-Type", "application/json"}}, "sheet=" .. sheet .. "&key=" .. key .. "&value=" .. SendData)

	local Data = Json.decode(Body)
	print(retJson)
	if data.result == "success" then
		return true
	else
		print("Database error:", data.error)
		return false
	end
end]]

function DoPost(sheet, key, data)
	--print(url)
	local json = Query.urlencode(Json.encode(data))

	local Link = url .. "?sheet=" .. sheet .. "&key=" .. key .. "&value=" .. json
	local Res, Body = Coro.request("POST", url, {{"Content-Type", "application/json"}, {"content-length", 0}}, nil)
	
	print(Body)
	--154 332

	--[[
	local data = Json.decode(Body)

	if data.result == "success" then
		return true
	else
		warn("Database error:", data.error)
		return false
	end]]
end

function Module:GetDatabase(sheet)
	local database = {}
	function database:PostAsync(key, value)
		return DoPost(sheet, key, value)
	end
	function database:GetAsync(key)
		return DoGet(sheet, key)
	end
	return database
end

return Module

--[[
game:WaitForChild'NetworkServer'

function decodeJson(json)
	local jsonTab = {} pcall(function ()
	jsonTab = httpService:JSONDecode(json)
	end) return jsonTab
end

function encodeJson(data)
	local jsonString = data pcall(function ()
	jsonString = httpService:JSONEncode(data)
	end) return jsonString
end

function doGet(sheet, key)
	local json = httpService:GetAsync(url .. "?sheet=" .. sheet .. "&key=" .. key)
	local data = decodeJson(json)
	if data.result == "success" then
		return data.value
	else
		warn("Database error:", data.error)
		return
	end
end

function doPost(sheet, key, data)
	local json = httpService:UrlEncode(encodeJson(data))
	local retJson = httpService:PostAsync(url, "sheet=" .. sheet .. "&key=" .. key .. "&value=" .. json, 2)
	local data = decodeJson(retJson)
	print(retJson)
	if data.result == "success" then
		return true
	else
		warn("Database error:", data.error)
		return false
	end
end

function module:GetDatabase(sheet)
	local database = {}
	function database:PostAsync(key, value)
		return doPost(sheet, key, value)
	end
	function database:GetAsync(key)
		return doGet(sheet, key)
	end
	return database
end]]



