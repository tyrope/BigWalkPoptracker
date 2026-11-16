-- ["and", [rules]] / ["or", [rules]] => all / any of the rules
function ParseMultiple(method, rules)
    if method == "and" then
        exitValue = false
    elseif method == "or" then
        exitValue = true
    else
        print("[BigWalk]ERR: Wrong method for ParseMultiple.")
        return nil
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
    if method ~= "all" and method ~= "any" and method ~= "from" then
        print("[BigWalk]ERR: Wrong method for ParseItems")
        return nil
    end
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
    print("[BigWalk]ERR: Trying to parse a location rule that doesn't exist?!")
    print(parentLoc)
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
    print("[BigWalkPack] ERR: Region not accessible, ever."..region)
    return false
end

-- Definitions provided at https://github.com/Grizfreak/BigWalk-archipelago/blob/master/apworld/README.md
function ParseRule(rule)
    if rule[1] == "true" then
        return true
    elseif rule[1] == "false" then
        return false
    elseif rule[1] == "and" or rule[1] == "or" then
        return ParseMultiple(rule[1], rule[2])
    elseif rule[1] == "has" then
        return ParseHas(rule[2],rule[3])
    elseif rule[1] == "all" or rule[1] == "any" then
        return ParseItems(rule[1], rule[2], nil)
    elseif rule[1] == "from" then
        return ParseItems(rule[1], rule[2], rule[3])
    elseif rule[1] == "loc" then
        return ParseLocation(rule[2])
    elseif rule[1] == "reg" then
        return ParseRegion(rule[2])
    end
    print("[BigWalkPack] ERR: Rule type not recognized: "..rule[1])
end

