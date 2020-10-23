return function(Data)

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

  
  App.route({
    method = "GET", 
    path = "/",
  }, function (req, res)
    local File = io.open("././WebsitePages/Home.html", "r")
    res.body = File:read("*a")
    File:close()
    res.headers["Content-Type"] = "text/html"
    res.code = 200
  end)

  App.route({
    method = "GET",
    path = "/discord", 
  }, function (req, res)
    local File = io.open("././WebsitePages/Discord.html", "r")
    res.body = File:read("*a")
    File:close()
    res.headers["Content-Type"] = "text/html"
    res.code = 200
  end)


  App.route({
    method = "GET", 
    path = "/discord/redirect", 
  }, function (req, res)
    local File = io.open("././WebsitePages/Logged.html", "r")
    res.body = File:read("*a")
    File:close()
    res.headers["Content-Type"] = "text/html"
    res.code = 200
  end)

  App.route({
    method = "GET", -- Filter on HTTP verb
    path = "/discord/user/:id", -- Filter on url patterns and capture some parameters.
  }, function (req, res)
    local File = io.open("././WebsitePages/UserPage.html", "r")
    local Read = File:read("*a")
    File:close()

    local User = Data.Client:getUser(req.params.id)

    

    res.body = ""
    
    res.headers["Content-Type"] = "text/html"
    res.code = 200
  end)

  App.route({
    method = "GET", -- Filter on HTTP verb
    path = "/partner", -- Filter on url patterns and capture some parameters.
  }, function (req, res)
    local File = io.open("././WebsitePages/Partner.html", "r")
    res.body = File:read("*a")
    File:close()
    res.headers["Content-Type"] = "text/html"
    res.code = 200
  end)

  
  App.start()


end