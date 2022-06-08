return function(Token)
    return require("../Tokens.lua")[Token] or os.getenv(string.upper(Token))
end