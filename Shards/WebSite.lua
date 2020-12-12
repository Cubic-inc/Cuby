return function(Data)

  local Tokens = require("././Tokens")
  local LoadPage = require("Code/Website/RenderPage")
  local Http = require("coro-http")
  local App = require('weblit-app')


  App.bind({
    host = "0.0.0.0",
    port = process.env["PORT"] or 3000
  })


  App.use(require('weblit-auto-headers'))
  App.use(require('weblit-etag-cache'))
  --App.use(require('weblit-logger'))

  App.route({
    method = "POST", 
    path = "/invite", 
  }, function (req, res)
    res.body = "<!DOCTYPE html>\n<html>\n<head>\n<meta http-equiv=\"refresh\" content=\"0; url=\'https://discord.gg/JjDEPCvj7z\'\" />\n</head>\n</html>"
    res.headers["Content-Type"] = "text/html"
    res.code = 200
  end)

  
  App.route({method = "GET", path = "/"}, function (req, res)

    res.body = LoadPage("././WebsitePages/Home.html")

    res.headers["Content-Type"] = "text/html"
    res.code = 200
  end)

  App.route({
    method = "GET",
    path = "/discord", 
  }, function (req, res)
    
    res.body = LoadPage("././WebsitePages/Discord.html")

    res.headers["Content-Type"] = "text/html"
    res.code = 200
  end)

  App.route({
    method = "GET",
    path = "/succes", 
  }, function (req, res)
    
    local Parms = require("Code/Website/GetParams")(req.path)
    local Replace = {message = Parms.message, reffer = Parms.reffer, reffertext = Parms.text}

    res.body = LoadPage("././WebsitePages/Succes.html", Replace)
    res.headers["Content-Type"] = "text/html"
    res.code = 200
  end)


  App.route({
    method = "GET", -- Filter on HTTP verb
    path = "/partner", -- Filter on url patterns and capture some parameters.
  }, function (req, res)
    res.body = LoadPage("././WebsitePages/Partner.html")
    res.headers["Content-Type"] = "text/html"
    res.code = 200
  end)

  App.route({method = "GET", path = "/login",}, function (req, res)

    local Query = require("Code/Website/GetParams")(req.path)
    local Http = require("coro-http")

    res.body = "err"
    print(req.path)
    print(Query.code)

    if Query.code then

      res.body = Query.code

      Params = {
        grant_type = 'authorization_code',
        client_id = Tokens.MODAPPKEY or os.getenv("MODAPPKEY"),
        client_secret = Tokens.MODAPPSECRET or os.getenv("MODAPPSECRET"),
        redirect_uri = "http://localhost:3000/users/" .. UserID .. "/" .. ActionType,
        code = Code,
        scope = "identify"
      }

      local Http = require("coro-http")
      
      
      local Res, Body = Http.request("POST", "https://discord.com/api/oauth2/token", {{"Content-Type", "application/x-www-form-urlencoded"}}, Query.stringify(Params))

      
    else
      local Url = "https://discord.com/api/oauth2/authorize?client_id=665886892801130516&redirect_uri=http%3A%2F%2Flocalhost%3A3000%2Flogin&response_type=code&scope=identify"
      res.body = "<!DOCTYPE html>\n<html>\n<head>\n<meta http-equiv=\"refresh\" content=\"0; url=\'" .. Url .. "\'\" />\n</head>\n</html>"
    end

    
    res.headers["Content-Type"] = "text/html"
    res.code = 200
  end)

  App.route({method = "GET", path = "/discord/partnerhook/:lang",}, require("Code/Website/WebHookFunctions").Start)

  App.route({method = "GET", path = "/discord/partnerhook/:lang/done", }, require("Code/Website/WebHookFunctions").Done)

  
  App.start()


end

--https://discord.com/api/oauth2/authorize?client_id=665886892801130516&redirect_uri=http%3A%2F%2Flocalhost%3A3000%2Flogin%2Fdone&response_type=code&scope=identify