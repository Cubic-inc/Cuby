-- See https://github.com/Dot-lua/TypeWriter/wiki/package.info.lua-format for more info

return { InfoVersion = 1, -- Dont touch this

    ID = "cuby", -- A unique id 
    Name = "Cuby",
    Description = "Discord bot",
    Version = "1.0.0",

    Author = {
        Developers = {
            "CoreByte"
        },
        Contributors = {}
    },

    Dependencies = {
        Luvit = {
            "SinisterRectus/discordia"
        },
        Git = {
            "GitSparTV/discordia-slash",
            "Bilal2453/discordia-interactions",
            "Bilal2453/discordia-components"
        },
        Dua = {}
    },

    Contact = {
        Website = "https://cubic-inc.ga",
        Source = "https://github.com/Dot-lua/TypeWriter/",
        Socials = {}
    },

    Entrypoints = {
        Main = "CubicInc.Cuby"
    }

}
