return function(App)

    App.route(
        {path = "/invite", method = "GET"}, 
        function(Request, Response, Go)

            Response.body = Readfile("./WebsiteData/Pages/Invite.html")
            Response.code = 200
            Response.headers["Content-Type"] = "text/html"


        end
    )

end