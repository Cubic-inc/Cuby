return function(Data)


  function LoadPage(Path)

    local File = io.open(Path, "r")
    local HTML = File:read("*a")

    local CssFile = io.open("././WebsitePages/Styles/TopBar.css", "r")
    local CssString = CssFile:read("*a")

    local TopFile = io.open("././WebsitePages/TopBar.html", "r")
    local TopHtml = TopFile:read("*a")


    local HTMLReplaced = Data.Libs.Code.ReplaceString(HTML, {topcss = CssString, tophtml = TopHtml})

    --[[
    print(Path)
    print(CssString)
    print(TopHtml)
    print(HTMLReplaced)]]

    File:close()
    CssFile:close()
    TopFile:close()

    return HTMLReplaced

  end

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
    path = "/discord/redirect", 
  }, function (req, res)
    
    res.body = LoadPage("././WebsitePages/Discord.html")

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
    
    res.body = LoadPage("././WebsitePages/Partner.html")

    res.headers["Content-Type"] = "text/html"
    res.code = 200
  end)

  
  App.start()


end