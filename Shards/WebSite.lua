return function(Data)

  local Tokens = require("././Tokens")
  local LoadPage = require("Code/Website/RenderPage")

  local App = require('weblit-app')


  App.bind({
    host = "0.0.0.0",
    port = process.env["PORT"] or 3000
  })


  App.use(require('weblit-auto-headers'))
  App.use(require('weblit-etag-cache'))

  App.route({
    method = "GET", 
    path = "/invite", 
  }, function (req, res)
    res.body = "<!DOCTYPE html>\n<html>\n<head>\n<meta http-equiv=\"refresh\" content=\"0; url=\'https://www.discord.gg/rBHegkm\'\" />\n</head>\n</html>"
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
    
    res.body = LoadPage("././WebsitePages/Succes.html")

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

  App.route({method = "GET", path = "/login/done",}, function (req, res)

    local Code = require("Code/Website/GetParams")(req.path)
    local Http = require("coro-http")

    if Code then

      

    end

    res.body = Code.code

    

    res.headers["Content-Type"] = "text/html"
    res.code = 200
  end)

  App.route({method = "GET", path = "/login",}, function (req, res)

    local Url = "https://discord.com/api/oauth2/authorize?client_id=665886892801130516&redirect_uri=http%3A%2F%2Flocalhost%3A3000%2Flogin%2Fdone&response_type=code&scope=identify"

    res.body = "<!DOCTYPE html>\n<html>\n<head>\n<meta http-equiv=\"refresh\" content=\"0; url=\'" .. Url .. "\'\" />\n</head>\n</html>"
    res.headers["Content-Type"] = "text/html"
    res.code = 200
  end)

  App.route({method = "GET", path = "/discord/partnerhook/:lang",}, require("Code/Website/WebHookFunctions").Start)

  App.route({method = "GET", path = "/discord/partnerhook/:lang/done", }, require("Code/Website/WebHookFunctions").Done)

  
  App.start()


end

--https://discord.com/api/oauth2/authorize?client_id=665886892801130516&redirect_uri=http%3A%2F%2Flocalhost%3A3000%2Flogin%2Fdone&response_type=code&scope=identify