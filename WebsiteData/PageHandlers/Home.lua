return function(App)

    App.route(
        {path = "/", method = "GET"}, 
        function(Request, Response, Go)

            Response.body = Readfile("./WebsiteData/Pages/Home.html")
            Response.code = 200
            Response.headers["Content-Type"] = "text/html"

            --print(Response.body)

        end
    )



end