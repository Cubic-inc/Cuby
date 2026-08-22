local BaseTable = {a = "a'", b = "b"} -- require("./Libs/VerifyEmbed.lua")

    print(BaseTable)

    local TableString = Json.encode(BaseTable)

    print(TableString)

    local CloneTable = Json.decode(TableString)

    print(CloneTable)