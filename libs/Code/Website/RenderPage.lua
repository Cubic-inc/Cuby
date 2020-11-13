return function(Path)

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