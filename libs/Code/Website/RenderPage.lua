return function(Path, Replace)

    Replace = Replace or {}

    local File = io.open(Path, "r")
    local HTML = File:read("*a")

    local CssFile = io.open("././WebsitePages/Styles/TopBar.css", "r")
    local CssString = CssFile:read("*a")

    local TopFile = io.open("././WebsitePages/TopBar.html", "r")
    local TopHtml = TopFile:read("*a")


    local ReplaceTable = {topcss = CssString, tophtml = TopHtml}

    for i, v in pairs(Replace) do
      ReplaceTable[i] = v
    end

    ---for i, v in pairs(ReplaceTable) do print(i, v) end


    local HTMLReplaced = Data.Libs.Code.ReplaceString(HTML, ReplaceTable)

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