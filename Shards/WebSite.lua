return function(Data)

    local App = require('weblit-app')

  -- Bind to localhost on port 3000 and listen for connections.
  App.bind({
    host = "0.0.0.0",
    port = process.env["PORT"] or 8080
  })

  -- Include a few useful middlewares.  Weblit uses a layered approach.
  App.use(require('weblit-logger'))
  App.use(require('weblit-auto-headers'))
  App.use(require('weblit-etag-cache'))

  -- This is a custom route handler
  App.route({
    method = "GET", -- Filter on HTTP verb
    path = "/", -- Filter on url patterns and capture some parameters.
  }, function (req, res)
    local File = io.open("././WebsitePages/Home.html", "r")
    res.body = File:read("*a")
    File:close()
    res.headers["Content-Type"] = "text/html"
    res.code = 200
  end)

  App.route({
    method = "GET", -- Filter on HTTP verb
    path = "/discord/", -- Filter on url patterns and capture some parameters.
  }, function (req, res)
    local File = io.open("././WebsitePages/Discord.html", "r")
    res.body = File:read("*a")
    File:close()
    res.headers["Content-Type"] = "text/html"
    res.code = 200
  end)

  --[[
  .route({
    method = "GET", -- Filter on HTTP verb
    path = "/bot/", -- Filter on url patterns and capture some parameters.
  }, function (req, res)
    local File = io.open("././WebsitePages/Bot.html", "r")
    res.body = File:read("*a")
    File:close()
    res.headers["Content-Type"] = "text/html"
    res.code = 200
  end)]]

  App.route({
    method = "GET", -- Filter on HTTP verb
    path = "/partner/", -- Filter on url patterns and capture some parameters.
  }, function (req, res)
    local File = io.open("././WebsitePages/Partner.html", "r")
    res.body = File:read("*a")
    File:close()
    res.headers["Content-Type"] = "text/html"
    res.code = 200
  end)

  -- Actually start the server
  App.start()


end