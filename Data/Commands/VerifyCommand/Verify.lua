local Json = require("json")
local Coro = require("coro-http")
local Wait = require("timer").sleep
--local TableToString = require("../../../../Libs/TableToString.lua")
local Table = table 
local String = string

return function(Data)
    local User = Data.Author
    local Channel = Data.Client:getChannel("665259318714564611")
    local VerifyMessage = Data.PreMSG
    local NormalText = Data.Author.mentionString .. " Welcome to the official **CUBIC INC DISCORD SERVER!**"
    local VerifyLink = "https://verify.eryn.io/api/user/" .. User.id
    local TenSpaces = "          "
    local Cooldown = false
    local GroupLink1 = "https://groups.roblox.com/v2/users/"
    local GroupLink2 = "/groups/roles"
    local GroupId = 3613394
    local RobloxData = {}
    local GroupLink = nil
    local CooldownTime = 15 * 100
    local InfoText = "Press the :repeat: reaction to retry (THIS DOES NOT START IT OVER AGAIN)"

    

    local VerifyEmbed = require("./VerifyEmbed.lua")

    
    
    VerifyMessage:update({
        content = NormalText,
        embed = VerifyEmbed, 
    })

    local NumberStrings = {"one", "two", "three", "four", "five"}
    local Emojis = {["true"] = ":white_check_mark:", ["false"] = ":negative_squared_cross_mark:"}
    local Progress = {false, false, false, false, false}
    local CurrentWorking = 1

    local CheckFunctions = {
        [1] = function()
                pcall(function()
                    Res, Body = Coro.request("GET", VerifyLink)
                    
                    Body = Json.decode(Body)
                    
                    RobloxData = Body
        
                    if Body.status == "ok" then
                        Progress[1] = true
                        GroupLink = GroupLink1 .. RobloxData.robloxId .. GroupLink2
                    end
                end)
                
            end,

        [2] = function()
                pcall(function()
                    Res, Body = Coro.request("GET", GroupLink)
                    
                    Body = Json.decode(Body)
                    
                    
        
                    if not Body.error then
                        for i, v in pairs(Body.data) do
                            if v.group.id == GroupId then
                                Progress[2] = true
                                break
                            end
                        end

                    else
                        
                    end
                end)
            end,

        [3] = function()
                Progress[3] = true
            end,

        [4] = function()
                Progress[4] = true
            end,

        [5] = function()
                Progress[5] = true
            end
    }

    VerifyEmbed = VerifyMessage.embed

    local FieldLength = #VerifyEmbed.fields

    Table.insert(VerifyEmbed.fields, {name = "Verify Status", value = "NO"})
    
    local VerifyStatus = VerifyEmbed.fields[FieldLength + 1]

    Table.insert(VerifyEmbed.fields, {name = "|", value = "Press the :repeat: reaction to retry (THIS DOES NOT START IT OVER AGAIN)"})

    local VerifyInfo = VerifyEmbed.fields[FieldLength + 2]

    Data.Client:on("raw", function(RawData)
        RawData = Json.decode(RawData)
        
        if RawData.t == "MESSAGE_REACTION_ADD" then
            --RawData = TableToString(RawData)
            --print(RawData)

            if RawData.d.member.user.id ~= User.id and RawData.d.member.user.id ~= Data.Client.user.id then
                VerifyMessage:removeReaction("🔁", RawData.d.member.user.id)
            elseif RawData.d.member.user.id == User.id then
                for i, v in pairs(Progress) do
                    if v == false then
                        CheckFunctions[i]()
                        CooldownStart()
                        break
                    end
                end
                
                if Progress[5] == true then
                    Wait(CooldownTime)
                    Wait(1)
                    VerifyMessage:hideEmbeds()
                    NormalText = User.mentionString .. " **VERIFYCATION COMPLETE!** Welcome to the server! \n If you need any help ask me or any staffmember!"
                    UpdateStatus()
                end
            end
        end
    end)

    function UpdateStatus()
        local GeneratedString = ""
        VerifyMessage:clearReactions()
        if Cooldown == false then
            VerifyMessage:addReaction("🔁")
        else
            
        end

        for i, v in pairs(Progress) do
            
            GeneratedString = GeneratedString .. TenSpaces .. ":" .. NumberStrings[i] .. ":" .. " " .. Emojis[tostring(v)] 
        end

        VerifyStatus.value = GeneratedString
        VerifyInfo.value = InfoText
        VerifyMessage:update({
            content = NormalText,
            embed = VerifyEmbed, 
        })
    end
    function CooldownStart()
        coroutine.wrap(function()
            if Cooldown == false then
                local OldInfo = InfoText
                Cooldown = true
                InfoText = ":cold_face: you are in cooldown please wait!"
                UpdateStatus()
                Wait(CooldownTime)
                InfoText = OldInfo
                Cooldown = false
                UpdateStatus()
            end
        end)()
    end
    --Updating the current state

    
    

    

    VerifyMessage:update({
        content = NormalText,
        embed = VerifyEmbed, 
    })

    

    CheckFunctions[1]()

    if Progress[1] == true then
        CheckFunctions[2]()
    end
    --CooldownStart()
    UpdateStatus()

end