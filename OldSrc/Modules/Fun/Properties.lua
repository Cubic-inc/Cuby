return {
    Name = "Fun",
    Main = require("./Main.lua"),

    Commands = {
        Cool = require("./Commands/Cool.lua"),
        Ping = require("./Commands/Ping.lua")
    }
}