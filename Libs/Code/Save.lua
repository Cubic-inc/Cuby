-- The variable below is the ID of the script you've created, you won't need
-- to enter any information other than this.

local scriptId = "AKfycbyxt-m0JKxrvY2dxm4LdTLK_5wvv_Xusdb9WQ0qRhZKU4Tk4kkA"

-- Touch anything below and you'll upset the script, and that's not a good thing.

local url = "https://script.google.com/macros/s/" .. scriptId .. "/exec"
local Coro = require("coro-http")
local Json = require("json")
local Wait = require("./Wait.lua")

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
	local json = Json.encode(data)
	local Res, Body = Coro.request("POST", url, {{"Content-Type", "application/json"}}, "sheet=" .. sheet .. "&key=" .. key .. "&value=" .. json)
	local data = Json.decode(Body)
	print(Body)
	if data.result == "success" then
		return true
	else
		warn("Database error:", data.error)
		return false
	end
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



