require("scripts.lib.bigwalkprinter")

-- ["and", [rules]] / ["or", [rules]] => all / any of the rules
function ParseMultiple(method, rules)
    if method == "and" then
        exitValue = false
    elseif method == "or" then
        exitValue = true
    end

    for _,rule in pairs(rules) do
        if ParseRule(rule, verbose) == exitValue then
            return exitValue
        end
    end
    return exitValue == false
end

function ConvertItemName(item)
    name = string.lower(item)
    name, _ = string.gsub(name, " ", "") -- NO SPACE!
    name, _ = string.gsub(name, "unlock", "") -- We don't use the word "unlock" here.
    return name
end

-- ["has", item, count] => at least count of item received
function ParseHas(item, count, verbose)
    item_obj = Tracker:FindObjectForCode(ConvertItemName(item))
    temp = item_obj.AcquiredCount >= count or (item_obj.Active and count == 1)
    if verbose then bwprint("INFO","ParseHas","("..item..","..count..") => ", temp) end
    return temp
end

-- ["all", [items]] / ["any", [items]] => one of each / one of any
-- ["from", [items], count] => at least count items in total among the list
function ParseItems(method, items, count, verbose)
    for _,item in pairs(items) do
        convName = ConvertItemName(item)
        amount = Tracker:FindObjectForCode(convName).AcquiredCount
        active = Tracker:FindObjectForCode(convName).Active
        if method == "all" and (amount == 0 and not active) then
            if verbose then bwprint("INFO","ParseItems","false") end
            return false
        elseif method == "any" and (amount > 0 or active) then
            if verbose then bwprint("INFO","ParseItems","true") end
            return true
        elseif method == "from" and amount > 0 then
            count = count - amount
            if count <= 0 then
                if verbose then bwprint("INFO","ParseItems","true") end
                return true
            end
        elseif method == "from" and active then
            count = count - 1
            if count <= 0 then
                if verbose then bwprint("INFO","ParseItems","true") end
                return true
            end
        end
    end
    if method == "all" then
        if verbose then bwprint("INFO","ParseItems","true") end
        return true
    elseif method == "any" or method == "from" then
        if verbose then bwprint("INFO","ParseItems","false") end
        return false
    else
        bwprint("ERROR","ParseItems","Unknown method.")
    end
end

-- ["loc", location] => that location is reachable (its region and its rule)
function ParseLocation(parentLoc, verbose)
    for _,loc in pairs(SLOT_LOGIC["locations"]) do
        if loc[1] == parentLoc then
            temp = ParseRule(loc[4]+1) and ParseRegion(loc[3])
            if verbose then print("[BigWalk] INFO: ParseLogcation::",temp) end
            return ParseRule(loc[4]+1) and ParseRegion(loc[3])
        end
    end
    bwprint("ERROR","ParseLocation","Rule location doesn't exist?!",parentLoc)
    return false
end

-- ["reg", region] => that region is reachable
function ParseRegion(region, verbose)
    if region == SLOT_LOGIC["origin"] then
        return true
    end
    for _,exit in pairs(SLOT_LOGIC["exits"]) do
        if exit[2] == region then
            return ParseRule(SLOT_LOGIC["rules"][exit[3]+1]) and ParseRegion(exit[1])
        end
    end
    bwprint("ERROR","ParseRegion","Not accessible, ever.",region)
    return false
end

-- Definitions provided at https://github.com/Grizfreak/BigWalk-archipelago/blob/master/apworld/README.md
function ParseRule(rule, verbose)
    if rule[1] == "true" then
        if verbose then bwprint("DEBUG","ParseRule","\"true\" rule is", true) end
        return true
    elseif rule[1] == "false" then
        if verbose then bwprint("DEBUG","ParseRule","\"false\" rule is", false) end
        return false
    elseif rule[1] == "and" or rule[1] == "or" then
        temp = ParseMultiple(rule[1], rule[2])
        if verbose then bwprint("DEBUG","ParseRule","\""..rule[1].."\" rule is", temp) end
        return temp
    elseif rule[1] == "has" then
        temp = ParseHas(rule[2],rule[3],verbose)
        if verbose then bwprint("DEBUG","ParseRule","\"has\" rule is", temp) end
        return temp
    elseif rule[1] == "all" or rule[1] == "any" then
        temp = ParseItems(rule[1], rule[2], nil, verbose)
        if verbose then bwprint("DEBUG","ParseRule","\""..rule[1].."\" rule is", temp) end
        return temp
    elseif rule[1] == "from" then
        temp = ParseItems(rule[1], rule[2], rule[3], verbose)
        if verbose then bwprint("DEBUG","ParseRule","\"from\" rule is", temp) end
        return temp
    elseif rule[1] == "loc" then
        temp = ParseLocation(rule[2], verbose)
        if verbose then bwprint("DEBUG","ParseRule","\"loc\" rule is", temp) end
        return temp
    elseif rule[1] == "reg" then
        temp = ParseRegion(rule[2], verbose)
        if verbose then bwprint("DEBUG","ParseRule","\"reg\" rule is", temp) end
        return temp
    end
    bwprint("ERROR","ParseRule","Rule type not recognized: "..rule[1])
end

