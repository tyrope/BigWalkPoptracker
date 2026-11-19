-- ["and", [rules]] / ["or", [rules]] => all / any of the rules
function ParseMultiple(method, rules)
    if method == "and" then
        exitValue = false
    elseif method == "or" then
        exitValue = true
    end

    for _,rule in pairs(rules) do
        if ParseRule(rule) == exitValue then
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
function ParseHas(item, count)
    item_obj = Tracker:FindObjectForCode(ConvertItemName(item))
    return item_obj.AcquiredCount >= count
end

-- ["all", [items]] / ["any", [items]] => one of each / one of any
-- ["from", [items], count] => at least count items in total among the list
function ParseItems(method, items, count)
    for _,item in pairs(items) do
        amount = Tracker:FindObjectForCode(ConvertItemName(item)).AcquiredCount
        if method == "all" and amount == 0 then
            return false
        elseif method == "any" and amount > 0 then
            return true
        elseif method == "from" and amount > 0 then
            count = count - amount
            if count <= 0 then
                return true
            end
        end
    end
    if method == "all" then
        return true
    elseif method == "any" or method == "from" then
        return false
    end
end

-- ["loc", location] => that location is reachable (its region and its rule)
function ParseLocation(parentLoc)
    for _,loc in pairs(SLOT_LOGIC["locations"]) do
        if loc[1] == parentLoc then
            return ParseRule(loc[4]+1)
        end
    end
    print("[BigWalk]ERROR: ParseLocation::Rule location doesn't exist?!", parentLoc)
    return false
end

-- ["reg", region] => that region is reachable
function ParseRegion(region)
    if region == SLOT_LOGIC["origin"] then
        return true
    end
    for _,exit in pairs(SLOT_LOGIC["exit"]) do
        if exit[2] == region then
            return CanReachRegion(region)
        end
    end
    print("[BigWalk] ERROR: ParseRegion::Not accessible, ever."..region)
    return false
end

-- Definitions provided at https://github.com/Grizfreak/BigWalk-archipelago/blob/master/apworld/README.md
function ParseRule(rule, verbose)
    if rule[1] == "true" then
        if verbose then print("[BigWalk] DEBUG: \"true\" rule is true.") end
        return true
    elseif rule[1] == "false" then
        if verbose then print("[BigWalk] DEBUG: \"false\" rule is false.") end
        return false
    elseif rule[1] == "and" or rule[1] == "or" then
        temp = ParseMultiple(rule[1], rule[2])
        if verbose then print("[BigWalk] DEBUG: \""..rule[1].."\" rule is:",temp) end
        return temp
    elseif rule[1] == "has" then
        temp = ParseHas(rule[2],rule[3])
        if verbose then print("[BigWalk] DEBUG: \"has\" rule is:",temp) end
        return temp
    elseif rule[1] == "all" or rule[1] == "any" then
        temp = ParseItems(rule[1], rule[2], nil)
        if verbose then print("[BigWalk] DEBUG: \""..rule[1].."\" rule is:",temp) end
        return temp
    elseif rule[1] == "from" then
        temp = ParseItems(rule[1], rule[2], rule[3])
        if verbose then print("[BigWalk] DEBUG: \"from\" rule is:",temp) end
        return temp
    elseif rule[1] == "loc" then
        temp = ParseLocation(rule[2])
        if verbose then print("[BigWalk] DEBUG: \"loc\" rule is:",temp) end
        return temp
    elseif rule[1] == "reg" then
        temp = ParseRegion(rule[2])
        if verbose then print("[BigWalk] DEBUG: \"reg\" rule is:",temp) end
        return temp
    end
    print("[BigWalk] ERROR: ParseRule::Rule type not recognized: "..rule[1])
end

