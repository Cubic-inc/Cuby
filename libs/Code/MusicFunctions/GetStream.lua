return function(url, MSG, Debug)

    local spawn = require('coro-spawn')
    local split = require('coro-split')
    local parse = require('url').parse

    url = url or ""

    --local Success = os.execute("youtube-dl  --extract-audio --audio-format mp3 --output \"CurrentPlayingFile.%(ext)s\" " .. url)

    local File = io.popen("youtube-dl  --extract-audio --audio-format m4a --output \"CurrentPlayingFile.%(ext)s\" " .. url)

    local Check = true

    for Line in File:lines() do

        Check = true

        if Debug then
            print("[DEBUG]: ", Line or "")
            MSG:send("[DEBUG]: " .. "```css\n" .. Line .. "```")
        end

        --print(Check)

    end

    --print(Check)

    File:close()

    local File = io.popen("youtube-dl -s --get-title " .. url)


    for Line in File:lines() do
        Title = Line
        break
    end

    File:close()

    return Check, Title

    --return Success

    --youtube-dl --extract-audio --audio-format mp3 --output "CurrentPlayingFile.%(ext)s" https://www.youtube.com/watch?v=RKW6rjnYEkc

    --[[
    local child = spawn('./youtube-dl', {
        args = {'-g', url},
        stdio = {nil, true, true}
      })
    
      local stream
      local function readstdout()
        local stdout = child.stdout
        for chunk in stdout.read do
          local mime = parse(chunk, true).query.mime
          if mime and mime:find('audio') then
            stream = chunk
          end
        end
        return pcall(stdout.handle.close, stdout.handle)
      end
    
      local function readstderr()
        local stderr = child.stderr
        for chunk in stderr.read do
          print(chunk)
        end
        return pcall(stderr.handle.close, stderr.handle)
      end
    
      split(readstdout, readstderr, child.waitExit)
    
      return stream and stream:gsub('%c', '')]]

end