function bwprint(level, method, message, attachment)
    if attachment ~= nil then
        print("[BigWalk] "..level..": "..method.."::"..message, attachment)
    else
        print("[BigWalk] "..level..": "..method.."::"..message)
    end
end

