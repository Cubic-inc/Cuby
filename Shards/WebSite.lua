return function(Data)

    require('weblit-app')

  -- Bind to localhost on port 3000 and listen for connections.
  .bind({
    host = "0.0.0.0",
    port = process.env["PORT"] or 8080
  })

  -- Include a few useful middlewares.  Weblit uses a layered approach.
  .use(require('weblit-logger'))
  .use(require('weblit-auto-headers'))
  .use(require('weblit-etag-cache'))

  -- This is a custom route handler
  .route({
    method = "GET", -- Filter on HTTP verb
    path = "/", -- Filter on url patterns and capture some parameters.
  }, function (req, res)
    --p(req) -- Log the entire request table for debugging fun

    local File = io.open("././WebsitePages/Home.html", "r")

    --print(File:read("*a"))

    res.body = File:read("*a")
    File:close()
    res.headers["Content-Type"] = "text/html"
    res.code = 200
  end)

  -- Actually start the server
  .start()


end