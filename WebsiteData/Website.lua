return function ()
    
    local App = require('weblit-app')
    local pathJoin = require('luvi').path.join
    local Static = require("weblit-static")

    local Pages = {

        Home = require("WebsiteData/PageHandlers/Home"),
        Invite = require("WebsiteData/PageHandlers/Invite"),
        Credits = require("WebsiteData/PageHandlers/Credits"),
        Join = require("WebsiteData/PageHandlers/Join"),

    } 

    _G.Readfile = require("fs").readFileSync

    App.bind({
        host = "0.0.0.0",
        port = 8080
    })

    --[[App.bind({
        host = "127.0.0.1",
        port = 8443
    })]]

    App.use(require('weblit-auto-headers'))
    App.use(require('weblit-etag-cache'))
    App.route({method = "GET", path = "/static/:path:"}, Static(pathJoin(module.dir, "../WebsiteData/Static/")))

    --[[

    App.route({method = "GET", path = "/invite"}, function (req, res, go)
        res.code = 200
        res.body = "<meta http-equiv=\"refresh\" content=\"0; url=\'https://discord.gg/JjDEPCvj7z\'\" />"
        res.headers["Content-Type"] = "text/html"
    end)]]
    
    Client:info("Starting website pages")

    for i, v in pairs(Pages) do
        Client:info("Starting " .. i)
        v(App)
        Client:info("Done starting " .. i)
    end

    App.start()

    print("Website started!")

end