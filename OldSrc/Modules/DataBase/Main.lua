return function(Params)
    local Client = Params.Client
    local Connection = Params.DataBaseConnection

    Connection:exec([[
        CREATE TABLE IF NOT EXISTS "Warnings" ( "UserID" INTEGER, "WarnID" INTEGER UNIQUE, "WarnReason" TEXT DEFAULT 'Unknown', "Severity" INTEGER DEFAULT 1, "Pardon" TEXT DEFAULT 'false', "ModeratorID" INTEGER, PRIMARY KEY("WarnID" AUTOINCREMENT) )
    ]])

    Connection:exec([[
        CREATE TABLE IF NOT EXISTS "UserData" ( "UserId" INTEGER UNIQUE, "XP" INTEGER DEFAULT 0, "Money" INTEGER DEFAULT 1000, PRIMARY KEY("UserId") )
    ]])
end