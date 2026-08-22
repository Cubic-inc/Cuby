local App = require('weblit-app')
local Http = require("coro-http")


function GetFound()

  local File = io.open("./Found.html", "r")

  local ToReturn = File:read("a+")

  File:close()

  return ToReturn

end

function GetNotFound()

  local File = io.open("./NotFound.html", "r")

  local ToReturn = File:read("a+")

  File:close()

  return ToReturn

end

function IsFound()

  local req, body = Http.request("GET", "https://cubic.redirectme.net")
    
  return req.code == 200

end

App.bind({
  host = "0.0.0.0",
  port = 8080
})

App.use(require('weblit-auto-headers'))
App.use(require('weblit-etag-cache'))

App.route({
  method = "GET",
  path = "/",
}, function (req, res, go)

    --print(IsFound())

    if IsFound() then
      res.body = GetFound()
    else
      res.body = GetNotFound()
    end

    

    res.headers["Content-Type"] = "text/html"
    res.code = 200
end)

App.start()