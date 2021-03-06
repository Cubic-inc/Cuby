return {

    Done = function (req, res)

        local Tokens = require("././Tokens")
    
        local Code = require("Code/Website/GetParams")(req.path)["code"]
        local Query = require("querystring")
        local Lang = req.params.lang
        print(Code)
    
        if Lang ~= "en" or Lang ~= "nl" then 
    
          res.body = "<head><meta http-equiv=\"refresh\" content=\"0; url=\'/\'\" /></head>"
    
        end
    
        if Code and Lang ~= "en" or Lang ~= "nl" then
    
          if Lang == "en" or Lang == "nl" then
            
            Params = {
                grant_type = 'authorization_code',
                client_id = Tokens.PARTNERAPPKEY or os.getenv("PARTNERAPPKEY"),
                client_secret = Tokens.PARTNERAPPSECRET or os.getenv("PARTNERAPPSECRET"),
                redirect_uri = "http://localhost:3000/discord/partnerhook/" .. Lang .. "/done",
                code = Code,
                scope = "webhook.incoming"
            }
    
            local Http = require("coro-http")
            
            
            local Res, Body = Http.request("POST", "https://discord.com/api/oauth2/token", {{"Content-Type", "application/x-www-form-urlencoded"}}, Query.stringify(Params))
            print(Query.stringify(Params))
            print(Body)

            local Decoded = require("json").decode(Body)


            if Lang == "en" then
                require("Code/PostWebhook")({content = "This discord is a partner of **CUBIC INC**\nThe **CUBIC INC** community is owned by @CoreByte#1161\nhttps://www.cubicdiscord.ga/"}, Decoded.webhook.url)
                require("Code/PostWebhook")({content = "You can now delete this webhook"}, Decoded.webhook.url)
            elseif Lang == "nl" then
                require("Code/PostWebhook")({content = "Deze discord is een partner van CUBIC INC.\n\nDe CUBIC INC. Community is geowned door @CoreByte#1161\nhttps://www.cubicdiscord.ga/"}, Decoded.webhook.url)
				        require("Code/PostWebhook")({content = "Je kan deze webhook nu verwijderen"}, Decoded.webhook.url)
            end
            res.body = "<head><meta http-equiv=\"refresh\" content=\"0; url=\'/succes\'\" /></head>"
    
          else
            res.body = "<head><meta http-equiv=\"refresh\" content=\"0; url=\'/\'\" /></head>"
            print("Invalid Lang")
            
          end
    
    
        else
          res.body = "<head><meta http-equiv=\"refresh\" content=\"0; url=\'/\'\" /></head>"
          print("Code not found")
        end
        
        --res.body = nil

        
    
        res.headers["Content-Type"] = "text/html"
        res.code = 200
      end,

      Start = function (req, res)
        local Encode = require("querystring").stringify
        local Url = "https://discord.com/api/oauth2/authorize?"
        local Tokens = require("././Tokens")
        local Query = require("querystring")
    
        local Lang = string.lower(req.params.lang)
    
        if Lang == "en" or Lang == "nl" then
    
          local Parms = {
    
            client_id = Tokens.PARTNERAPPKEY or os.getenv("PARTNERAPPKEY"),
            redirect_uri = "https://cubic.redirectme.net/discord/partnerhook/" .. Lang .. "/done",
            response_type = "code",
            scope = "webhook.incoming"

          }

          if Lang == "en" then
            Parms.redirect_uri = "http://localhost:3000/discord/partnerhook/en/done"
          elseif Lang == "nl" then
            Parms.redirect_uri = "http://localhost:3000/discord/partnerhook/nl/done"
          end

          print(Parms.redirect_uri)
    
          res.body = "<!DOCTYPE html>\n<html>\n<head>\n<meta http-equiv=\"refresh\" content=\"0; url=\'" .. Url .. Encode(Parms) .. "\'\" />\n</head>\n</html>"
    
        else
          res.body = "<head><meta http-equiv=\"refresh\" content=\"0; url=\'/\'\" /></head>"
        end
    
        
        res.headers["Content-Type"] = "text/html"
        res.code = 200
      end


}