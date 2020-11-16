return function(url)

    local spawn = require('coro-spawn')
    local split = require('coro-split')
    local parse = require('url').parse

    local Success = os.execute("./youtube-dl  --extract-audio --audio-format mp3 --output \"CurrentPlayingFile.%(ext)s\" " .. url)

    return Success

    --youtube-dl --extract-audio --audio-format mp3 --output "CurrentPlayingFile.%(ext)s" https://www.youtube.com/watch?v=RKW6rjnYEkc

    

end