return function(App)

    --[[
    App.route(
    {path = "/", method = "GET", host = "join.cubicinc.ga"}, 
    function(Request, Response, Go)
    
        Response.body = Readfile("./WebsiteData/Pages/Join.html")
        Response.code = 200
        Response.headers["Content-Type"] = "text/html"
    
    end)]]

end
