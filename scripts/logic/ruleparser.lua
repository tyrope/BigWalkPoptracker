require("scripts.lib.bigwalkprinter")

-- ["and", [rules]] / ["or", [rules]] => all / any of the rules
function ParseMultiple(method, rules)
    normalCount = 0
    oolCount = 0
    noneCount = 0
    for _, rule in pairs(rules) do
        r = ParseRule(rule, verbose)
        if r == AccessibilityLevel.None then
            noneCount = noneCount +1
        elseif r == AccessibilityLevel.SequenceBreak then
            oolCount = oolCount +1
        elseif r == AccessibilityLevel.Normal then
            normalCount = normalCount +1
        end
    end

    if method == "and" then
        if noneCount > 0 then
            return AccessibilityLevel.None
        elseif oolCount > 0 then
            return AccessibilityLevel.SequenceBreak
        elseif normalCount > 0 then
            return AccessibilityLevel.Normal
        else
            bwprint("ERROR","ParseMultiple","AND rule parsed with 0 counts.")
        end
    elseif method == "or" then
        if normalCount > 0 then
            return AccessibilityLevel.Normal
        elseif oolCount > 0 then
            return AccessibilityLevel.SequenceBreak
        elseif noneCount > 0 then
            return AccessibilityLevel.None
        else
            bwprint("ERROR","ParseMultiple","OR rule parsed with 0 counts.")
        end
    end
    return AccessibilityLevel.Inspect --TODO: Actually scream and die.
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
    if item_obj.AcquiredCount >= count or (item_obj.Active and count == 1) then
        -- Normal access.
        temp = AccessibilityLevel.Normal
    elseif item == "Left Arch Door" or item == "Right Arch Door" then
        -- This is blocked only by a shortcut.
        temp = AccessibilityLevel.SequenceBreak
    else
        -- No access.
        temp = AccessibilityLevel.None
    end
    if verbose then bwprint("DEBUG","ParseHas","("..item..","..count..")", temp) end
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
            if verbose then bwprint("DEBUG","ParseItems","false") end
            return AccessibilityLevel.None
        elseif method == "any" and (amount > 0 or active) then
            if verbose then bwprint("DEBUG","ParseItems","true") end
            return AccessibilityLevel.Normal
        elseif method == "from" and amount > 0 then
            count = count - amount
            if count <= 0 then
                if verbose then bwprint("DEBUG","ParseItems","true") end
                return AccessibilityLevel.Normal
            end
        elseif method == "from" and active then
            count = count - 1
            if count <= 0 then
                if verbose then bwprint("DEBUG","ParseItems","true") end
                return AccessibilityLevel.Normal
            end
        end
    end
    if method == "all" then
        if verbose then bwprint("DEBUG","ParseItems","true") end
        return AccessibilityLevel.Normal
    elseif method == "any" or method == "from" then
        if verbose then bwprint("DEBUG","ParseItems","false") end
        return AccessibilityLevel.None
    else
        bwprint("ERROR","ParseItems","Unknown method.")
    end
end

-- ["loc", location] => that location is reachable (its region and its rule)
function ParseLocation(parentLoc, verbose)
    for _,loc in pairs(SLOT_LOGIC["locations"]) do
        if loc[1] == parentLoc then
            temp = combineAccess(ParseRule(loc[4]+1,verbose), ParseRegion(loc[3],verbose))
            if verbose then bwprint("DEBUG","ParseLocation",temp) end
            return temp
        end
    end
    bwprint("ERROR","ParseLocation","Rule location doesn't exist?!",parentLoc)
    return AccessibilityLevel.None
end

-- ["reg", region] => that region is reachable
function ParseRegion(region, verbose)
    if region == SLOT_LOGIC["origin"] then
        return AccessibilityLevel.Normal
    end
    for _,exit in pairs(SLOT_LOGIC["exits"]) do
        if exit[2] == region then
            rule = ParseRule(SLOT_LOGIC["rules"][exit[3]+1])
            region = ParseRegion(exit[1])
            return combineAccess(rule, region)
        end
    end
    bwprint("ERROR","ParseRegion","Not accessible, ever.",region)
    return AccessibilityLevel.None
end

function combineAccess(locAccess, regAccess)
    if regAccess == AccessibilityLevel.None then
        -- Region's inaccessible.
        return AccessibilityLevel.None
    elseif regAccess == AccessibilityLevel.SequenceBreak then
        -- Region's not-in-logic but accessible.
        if locAccess ~= AccessibilityLevel.None then
            -- Location's not inaccessible. Sequence Break.
            return AccessibilityLevel.SequenceBreak
        else
            -- Location's inaccessible.
            return AccessibilityLevel.None
        end
    elseif regAccess == AccessibilityLevel.Normal then
        -- Region's In-logic, so the location sets the access.
        return locAccess
    end
end

-- Definitions provided at https://github.com/Grizfreak/BigWalk-archipelago/blob/master/apworld/README.md
function ParseRule(rule, verbose)
    if rule[1] == "true" then
        if verbose then bwprint("DEBUG","ParseRule","\"true\" rule") end
        return AccessibilityLevel.Normal
    elseif rule[1] == "false" then
        if verbose then bwprint("DEBUG","ParseRule","\"false\" rule") end
        return AccessibilityLevel.None
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

