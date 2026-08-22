local Json = require("json")
local Coro = require("coro-http")
local Wait = require("timer").sleep
local TableToString = require("./Libs/TableToString.lua")
local Table = table 
local String = string


return {

{
    Command = "ping";
    Aliases	= {"hey", "hello"};
    ModCmd = false;
    OwnerCmd = false;
    Description = "If the bot is online it should return 'pong'";
    Args = {};
    Function = require("./Data/Commands/Ping.lua")
};

{
    Command = "cool";
    Aliases	= {};
    ModCmd = false;
    OwnerCmd = false;
    Description = "Looks up how cool you are with the 'official' discord API";
    Args = {};
    Function = require("./Data/Commands/Cool.lua")
};

{
    Command = "emojify";
    Aliases	= {};
    ModCmd = false;
    OwnerCmd = true;
    Description = "Emojifys a string!";
    Args = {"String"};
    Function = require("./Data/Commands/Emojify/emojify.lua")
};

{
    Command = "verify";
    Aliases	= {};
    ModCmd = false;
    OwnerCmd = true;
    Description = "";
    Args = {};
    Function = require("./Data/Commands/VerifyCommand/Verify.lua")
};

{
    Command = "face";
    Aliases	= {};
    ModCmd = false;
    OwnerCmd = true;
    Description = "";
    Args = {};
    Function = require("./Data/Commands/FaceCommand/Face.lua")
};

}