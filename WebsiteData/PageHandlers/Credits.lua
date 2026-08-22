return function(App)

    App.route(
        {path = "/partners", method = "GET"}, 
        function(Request, Response, Go)

            Response.body = Readfile("./WebsiteData/Pages/Credits.html")
            Response.code = 200
            Response.headers["Content-Type"] = "text/html"


        end
    )

end